#!/usr/bin/env bash
set -euo pipefail

peers_dir=/etc/wireguard/peers
users_db=/etc/wireguard/users
networks_db=/etc/wireguard/networks
iface=wg0
endpoint=wg.m11s.de:51820

die() {
  echo "error: $*" >&2
  exit 1
}

server_pubkey() { wg show "${iface}" public-key; }

user_subnet() {
  grep "^${1} " "${users_db}" | awk '{print $2}' || die "unknown user: ${1}"
}

taken_ips() {
  local dir="${peers_dir}/${1}"
  [[ -d "${dir}" ]] || return 0
  grep -rh "AllowedIPs" "${dir}/" 2>/dev/null |
    awk '{print $3}' | tr ',' '\n' | tr -d ' ' |
    grep '/32$' | cut -d/ -f1
}

ip_to_int() {
  local a b c d
  IFS='.' read -r a b c d <<<"${1}"
  echo $(((a << 24) | (b << 16) | (c << 8) | d))
}

int_to_ip() {
  echo "$(((${1} >> 24) & 255)).$(((${1} >> 16) & 255)).$(((${1} >> 8) & 255)).$((${1} & 255))"
}

subnet_range() {
  # outputs: <start_int> <end_int>
  local net prefix net_int mask
  IFS='/' read -r net prefix <<<"${1}"
  net_int=$(ip_to_int "${net}")
  mask=$(((0xFFFFFFFF << (32 - prefix)) & 0xFFFFFFFF))
  local start=$((net_int & mask))
  echo "${start} $((start + (1 << (32 - prefix)) - 1))"
}

subnets_overlap() {
  read -r s1_start s1_end <<<"$(subnet_range "${1}")"
  read -r s2_start s2_end <<<"$(subnet_range "${2}")"
  ((s1_start <= s2_end && s2_start <= s1_end))
}

check_network_collisions() {
  local subnet=${1}
  local skip_subnet=${2:-}

  # check against existing networks
  [[ -f "${networks_db}" ]] && while read -r existing label; do
    [[ "${existing}" == "#"* || -z "${existing}" ]] && continue
    [[ "${existing}" == "${skip_subnet}" ]] && continue
    subnets_overlap "${subnet}" "${existing}" &&
      die "collision: ${subnet} overlaps with ${existing} (${label})"
  done <"${networks_db}"

  # check against user peer subnets
  while read -r user user_subnet; do
    [[ "${user}" == "#"* || -z "${user}" ]] && continue
    subnets_overlap "${subnet}" "${user_subnet}" &&
      die "collision: ${subnet} overlaps with WG peer subnet ${user_subnet} (user: ${user})"
  done <"${users_db}"
}

client_allowed_ips() {
  local allowed="10.13.0.0/24"
  [[ -f "${networks_db}" ]] && while read -r subnet _; do
    [[ "${subnet}" == "#"* || -z "${subnet}" ]] && continue
    allowed="${allowed}, ${subnet}"
  done <"${networks_db}"
  echo "${allowed}"
}

next_ip() {
  local subnet=${1}
  shift
  local net prefix net_int mask network broadcast i candidate taken_ip skip
  IFS='/' read -r net prefix <<<"${subnet}"
  net_int=$(ip_to_int "${net}")
  mask=$(((0xFFFFFFFF << (32 - prefix)) & 0xFFFFFFFF))
  network=$((net_int & mask))
  broadcast=$((network + (1 << (32 - prefix)) - 1))
  for ((i = network + 1; i < broadcast; i++)); do
    candidate=$(int_to_ip "${i}")
    skip=0
    for taken_ip in "$@"; do
      [[ "${taken_ip}" == "${candidate}" ]] && skip=1 && break
    done
    [[ "${skip}" -eq 1 ]] || {
      echo "${candidate}"
      return 0
    }
  done
  die "subnet ${subnet} exhausted"
}

peer_wg_ip() {
  grep "AllowedIPs" "${1}" | awk '{print $3}' | tr ',' '\n' | tr -d ' ' | grep '/32$' | head -1 | cut -d/ -f1
}

peer_extra_subnets() {
  grep "AllowedIPs" "${1}" | awk '{print $3}' | tr ',' '\n' | tr -d ' ' | grep -v '/32$' | grep -v '/128$' | grep -v '^$'
}

add_routes() {
  local gw
  gw=$(peer_wg_ip "${1}")
  [[ -n "${gw}" ]] || return 0
  while IFS= read -r subnet; do
    ip route replace "${subnet}" via "${gw}" dev "${iface}" metric 1000
    echo "route: ${subnet} via ${gw} metric 1000"
  done < <(peer_extra_subnets "${1}")
}

del_routes() {
  while IFS= read -r subnet; do
    ip route del "${subnet}" 2>/dev/null && echo "route removed: ${subnet}" || true
  done < <(peer_extra_subnets "${1}")
}

cmd_load() {
  local tmp
  tmp=$(mktemp)
  # shellcheck disable=SC2064
  trap "rm -f ${tmp}" EXIT
  find "${peers_dir}" -name '*.conf' -exec cat {} \; >"${tmp}"
  [ -s "${tmp}" ] && wg addconf "${iface}" "${tmp}"
  while IFS= read -r f; do
    add_routes "${f}"
  done < <(find "${peers_dir}" -name '*.conf')
}

cmd_add() {
  local user=${1:?usage: wg-peers add <user> <device> [extra-subnet ...]}
  local device=${2:?usage: wg-peers add <user> <device> [extra-subnet ...]}
  shift 2

  local dir="${peers_dir}/${user}"
  local conf="${dir}/${device}.conf"
  [[ ! -f "${conf}" ]] || die "peer already exists: ${user}/${device}"
  mkdir -p "${dir}"

  local subnet
  subnet=$(user_subnet "${user}")

  mapfile -t taken < <(taken_ips "${user}")
  local ip
  ip=$(next_ip "${subnet}" "${taken[@]+"${taken[@]}"}")

  local privkey pubkey psk allowed_ips
  privkey=$(wg genkey)
  pubkey=$(echo "${privkey}" | wg pubkey)
  psk=$(wg genpsk)
  allowed_ips="${ip}/32"
  for s in "$@"; do
    allowed_ips="${allowed_ips}, ${s}"
  done

  install -m 600 /dev/null "${conf}"
  cat >"${conf}" <<CONF
[Peer]
# device=${device}
PublicKey = ${pubkey}
PresharedKey = ${psk}
AllowedIPs = ${allowed_ips}
CONF

  wg addconf "${iface}" "${conf}"
  add_routes "${conf}"

  local client_allowed
  client_allowed=$(client_allowed_ips)

  local client_conf
  client_conf=$(
    cat <<CCNF

# save this — private key is not stored on the server

[Interface]
Address = ${ip}/32
PrivateKey = ${privkey}

[Peer]
PublicKey = $(server_pubkey)
PresharedKey = ${psk}
AllowedIPs = ${client_allowed}
Endpoint = ${endpoint}
PersistentKeepalive = 25
CCNF
  )
  echo "${client_conf}"
  echo ""
  echo "${client_conf}" | qrencode -t ansiutf8
}

cmd_del() {
  local user=${1:?usage: wg-peers del <user> <device>}
  local device=${2:?usage: wg-peers del <user> <device>}
  local conf="${peers_dir}/${user}/${device}.conf"
  [[ -f "${conf}" ]] || die "no such peer: ${user}/${device}"

  local pubkey
  pubkey=$(grep "PublicKey" "${conf}" | awk '{print $3}')

  del_routes "${conf}"
  rm "${conf}"
  wg set "${iface}" peer "${pubkey}" remove
  echo "removed ${user}/${device}"
}

cmd_list() {
  local filter=${1:-"*"}
  local found=0
  for f in "${peers_dir}/${filter}/"*.conf; do
    [[ -f "${f}" ]] || continue
    found=1
    local user device ip pubkey
    user=$(basename "$(dirname "${f}")")
    device=$(basename "${f}" .conf)
    ip=$(peer_wg_ip "${f}")
    pubkey=$(grep "PublicKey" "${f}" | awk '{print $3}')
    printf "%-12s %-16s %-16s %s\n" "${user}" "${device}" "${ip}" "${pubkey:0:8}…"
  done
  ((found)) || echo "no peers found"
}

cmd_useradd() {
  local user=${1:?usage: wg-peers useradd <user> <subnet>}
  local subnet=${2:?usage: wg-peers useradd <user> <subnet>}
  grep -q "^${user} " "${users_db}" && die "user already exists: ${user}"
  check_network_collisions "${subnet}"
  echo "${user} ${subnet}" >>"${users_db}"
  mkdir -p "${peers_dir}/${user}"
  echo "added user ${user} → ${subnet}"
}

cmd_netadd() {
  local subnet=${1:?usage: wg-peers netadd <subnet> <label>}
  local label=${2:?usage: wg-peers netadd <subnet> <label>}
  check_network_collisions "${subnet}"
  touch "${networks_db}"
  echo "${subnet} ${label}" >>"${networks_db}"
  echo "added network ${subnet} (${label})"
}

cmd_netdel() {
  local subnet=${1:?usage: wg-peers netdel <subnet>}
  [[ -f "${networks_db}" ]] || die "no networks defined"
  grep -q "^${subnet} " "${networks_db}" || die "network not found: ${subnet}"
  grep -v "^${subnet} " "${networks_db}" >"${networks_db}.tmp"
  mv "${networks_db}.tmp" "${networks_db}"
  echo "removed network ${subnet}"
}

cmd_netlist() {
  [[ -f "${networks_db}" ]] || {
    echo "no networks defined"
    return 0
  }
  while read -r subnet label; do
    [[ "${subnet}" == "#"* || -z "${subnet}" ]] && continue
    printf "%-20s %s\n" "${subnet}" "${label}"
  done <"${networks_db}"
}

case "${1:-}" in
load) cmd_load ;;
add) cmd_add "${@:2}" ;;
del) cmd_del "${@:2}" ;;
list) cmd_list "${@:2}" ;;
useradd) cmd_useradd "${@:2}" ;;
netadd) cmd_netadd "${@:2}" ;;
netdel) cmd_netdel "${@:2}" ;;
netlist) cmd_netlist ;;
*)
  cat >&2 <<'USAGE'
usage: wg-peers <command> [args]
  add     <user> <device> [subnet ...]   add peer, generate client config
  del     <user> <device>                remove peer
  list    [user]                         list peers
  useradd <user> <subnet>                add user with WG subnet
  netadd  <subnet> <label>               register LAN network
  netdel  <subnet>                       remove LAN network
  netlist                                list LAN networks
  load                                   load all peers + routes (postSetup)
USAGE
  exit 1
  ;;
esac
