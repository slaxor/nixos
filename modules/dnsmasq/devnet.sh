#!/usr/bin/env bash
# shellcheck shell=bash
[ "$(id -u)" -eq 0 ] || exec sudo "$0" "$@"
set -euo pipefail

tmp_dir=/tmp/devnet
# shellcheck disable=SC2174
mkdir -m 755 -p "${tmp_dir}"

pid_file="${tmp_dir}/dnsmasq.pid"
lease_file="${tmp_dir}/dnsmasq.lease"
config_file="${tmp_dir}/dnsmasq.conf"
tftp_dir="${tmp_dir}/tftpboot"
interface="eth0"
network="192.168.1.0/24"
addr="254"
verbose=false
bootfile=""

cleanup() {
  [[ -f "${pid_file}" ]] && sudo kill "$(cat "${pid_file}")" 2>/dev/null || true
  sudo ip addr del "${base}.${addr}/${netmask}" dev "${interface}" 2>/dev/null || true
  sudo ip link set dev "${interface}" down
  rm -rf "${tmp_dir}"
}
trap cleanup EXIT

# Derive netmask from CIDR prefix length (e.g. /24 -> 255.255.255.0)
calc_netmask() {
  local prefix="${1#*/}"
  local mask=0
  local i
  for ((i = 0; i < prefix; i++)); do
    mask=$(((mask >> 1) | 0x80000000))
  done
  printf "%d.%d.%d.%d\n" \
    $(((mask >> 24) & 0xff)) \
    $(((mask >> 16) & 0xff)) \
    $(((mask >> 8) & 0xff)) \
    $((mask & 0xff))
}

# Strip host part from CIDR to get base network IP (e.g. 192.168.1.0/24 -> 192.168.1)
calc_base() {
  local net="${1%/*}"
  echo "${net%.*}"
}

while getopts "i:n:a:vf:" opt; do
  case "${opt}" in
  i) interface="${OPTARG}" ;;
  n) network="${OPTARG}" ;;
  a) addr="${OPTARG}" ;;
  v) verbose=true ;;
  f) bootfile="${OPTARG}" ;;
  *)
    echo "Usage: devnet <up|down|status> [-i <interface>] [-n <network>] [-a <addr>] [-v] [-f <filename>]"
    exit 1
    ;;
  esac
done
shift $((OPTIND - 1))

[[ "${network}" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}$ ]] || {
  echo "Invalid network format. Use CIDR notation (e.g., 192.168.1.0/24)"
  exit 1
}

base="$(calc_base "${network}")"
netmask="$(calc_netmask "${network}")"

case "${1:-}" in
up)
  mkdir -m 755 "${tftp_dir}"
  # sudo chown nobody:nogroup "${tftp_dir}"
  echo "Starting devnet on ${interface} (${base}.${addr}/${netmask})..."
  sudo ip link set dev "${interface}" up
  sudo ip addr add "${base}.${addr}/${netmask}" dev "${interface}" || true
  cat >"${config_file}" <<EOF
interface=${interface}
port=0
enable-tftp
tftp-root=${tftp_dir}
dhcp-leasefile=${lease_file}
${bootfile:+dhcp-boot=${bootfile}}
dhcp-range=${base}.1,${base}.253,12h
dhcp-option=option:router,${base}.${addr}
bind-interfaces
pid-file=${pid_file}
${verbose:+log-dhcp}
no-daemon
EOF

  if ${verbose}; then
    sudo dnsmasq -C "${config_file}" -x "${pid_file}" -q
  else
    sudo dnsmasq -C "${config_file}" -x "${pid_file}"
  fi
  echo "Ready. TFTP root: ${tftp_dir}"
  ;;

down)
  echo "Stopping devnet..."
  cleanup
  ;;

status)
  if [[ -f "${pid_file}" ]]; then
    echo "devnet running (PID: $(cat "${pid_file}"))"
    echo "Interface: ${interface} (IP: ${base}.${addr})"
    echo "TFTP root: ${tftp_dir}"
    [[ -n "${bootfile}" ]] && echo "Bootfile: ${bootfile}"
    ${verbose} && echo "Verbose: enabled"
  else
    echo "devnet stopped"
  fi
  ;;

*)
  echo "Usage: devnet <up|down|status> [-i <interface>] [-n <network>] [-a <addr>] [-v] [-f <filename>]"
  exit 1
  ;;
esac
