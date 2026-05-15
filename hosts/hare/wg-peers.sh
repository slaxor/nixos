#!/usr/bin/env bash
set -euo pipefail

PEERS_DIR=/etc/wireguard/peers
USERS_DB=/etc/wireguard/users
IFACE=wg0
ENDPOINT=wg.m11s.de:51820

die() {
  echo "error: $*" >&2
  exit 1
}
need() { [[ -n "${!1:-}" ]] || die "missing argument: $1"; }

server_pubkey() { wg show "${IFACE}" public-key; }

user_subnet() {
  local user=${1}
  grep "^${user} " "${USERS_DB}" | awk '{print $2}' || die "unknown user: ${user}"
}

taken_ips() {
  local user=${1}
  local dir="${PEERS_DIR}/${user}"
  [[ -d "${dir}" ]] || return 0
  grep -rh "AllowedIPs" "${dir}/" 2>/dev/null | awk '{print $3}' | cut -d/ -f1
}

next_ip() {
  local subnet=${1}
  shift
  python3 - "${subnet}" "$@" <<'EOF'
import sys, ipaddress
net = ipaddress.ip_network(sys.argv[1], strict=False)
taken = set(sys.argv[2:])
for h in net.hosts():
    if str(h) not in taken:
        print(h)
        sys.exit(0)
print("error: subnet exhausted", file=sys.stderr)
sys.exit(1)
EOF
}

cmd_add() {
  local user=${1:?usage: wg-peers add <user> <device>}
  local device=${2:?usage: wg-peers add <user> <device>}
  local dir="${PEERS_DIR}/${user}"
  local conf="${dir}/${device}.conf"

  [[ ! -f "${conf}" ]] || die "peer already exists: ${user}/${device}"
  mkdir -p "${dir}"

  local subnet
  subnet=$(user_subnet "${user}")

  mapfile -t taken < <(taken_ips "${user}")
  local ip
  ip=$(next_ip "${subnet}" "${taken[@]+"${taken[@]}"}")

  local privkey pubkey psk
  privkey=$(wg genkey)
  pubkey=$(echo "${privkey}" | wg pubkey)
  psk=$(wg genpsk)

  install -m 600 /dev/null "${conf}"
  cat >"${conf}" <<EOF
[Peer]
# device=${device}
PublicKey = ${pubkey}
PresharedKey = ${psk}
AllowedIPs = ${ip}/32
EOF

  wg addconf "${IFACE}" "${conf}"

  local client_conf
  client_conf=$(
    cat <<EOF

# save this — private key is not stored on the server

[Interface]
Address = ${ip}/32
PrivateKey = ${privkey}

[Peer]
PublicKey = $(server_pubkey)
PresharedKey = ${psk}
AllowedIPs = 10.13.0.0/24
Endpoint = ${ENDPOINT}
PersistentKeepalive = 25
EOF
  )

  echo "${client_conf}"
  echo ""
  echo "${client_conf}" | qrencode -t ansiutf8
}

cmd_del() {
  local user=${1:?usage: wg-peers del <user> <device>}
  local device=${2:?usage: wg-peers del <user> <device>}
  local conf="${PEERS_DIR}/${user}/${device}.conf"

  [[ -f "${conf}" ]] || die "no such peer: ${user}/${device}"

  local pubkey
  pubkey=$(grep "PublicKey" "${conf}" | awk '{print $3}')

  rm "${conf}"
  wg set "${IFACE}" peer "${pubkey}" remove
  echo "removed ${user}/${device}"
}

cmd_list() {
  local filter=${1:-"*"}
  local found=0
  for f in "${PEERS_DIR}/${filter}/"*.conf; do
    [[ -f "${f}" ]] || continue
    found=1
    local user device ip pubkey
    user=$(basename "$(dirname "${f}")")
    device=$(basename "${f}" .conf)
    ip=$(grep "AllowedIPs" "${f}" | awk '{print $3}' | cut -d/ -f1)
    pubkey=$(grep "PublicKey" "${f}" | awk '{print $3}')
    printf "%-12s %-16s %-16s %s\n" "${user}" "${device}" "${ip}" "${pubkey:0:8}…"
  done
  ((found)) || echo "no peers found"
}

cmd_useradd() {
  local user=${1:?usage: wg-peers useradd <user> <subnet>}
  local subnet=${2:?usage: wg-peers useradd <user> <subnet>}
  grep -q "^${user} " "${USERS_DB}" && die "user already exists: ${user}"
  echo "${user} ${subnet}" >>"${USERS_DB}"
  mkdir -p "${PEERS_DIR}/${user}"
  echo "added user ${user} → ${subnet}"
}

case "${1:-}" in
add) cmd_add "${@:2}" ;;
del) cmd_del "${@:2}" ;;
list) cmd_list "${@:2}" ;;
useradd) cmd_useradd "${@:2}" ;;
*)
  echo "usage: wg-peers <add|del|list|useradd> [args]" >&2
  exit 1
  ;;
esac
