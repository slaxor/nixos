#!/usr/bin/env bash
set -euo pipefail

now=$(date +%s)

die() { echo "error: $*" >&2; exit 1; }
require() { command -v "$1" &>/dev/null || die "$1 not found"; }

require wg
require ip

fmt_ago() {
  local secs=$(( now - $1 ))
  if   (( secs < 60   )); then echo "${secs}s ago"
  elif (( secs < 3600 )); then echo "$(( secs / 60 ))m ago"
  else echo "$(( secs / 3600 ))h $(( (secs % 3600) / 60 ))m ago"
  fi
}

stale_threshold=${WG_STALE_SECS:-180}

interfaces=$(wg show interfaces)
[[ -n "${interfaces}" ]] || die "no WireGuard interfaces found"

for iface in ${interfaces}; do
  echo "══════════════════════════════════════════"
  echo "  interface: ${iface}"
  echo "══════════════════════════════════════════"

  ip -s -s link show "${iface}" | awk '
    /RX:/ {
      getline; rx_bytes=$1; rx_packets=$2; rx_errors=$3; rx_dropped=$4; rx_missed=$5
      getline  # "RX errors:" header line
      getline; rx_err_length=$1; rx_err_crc=$2; rx_err_frame=$3; rx_err_fifo=$4; rx_err_missed=$5
    }
    /TX:/ {
      getline; tx_bytes=$1; tx_packets=$2; tx_errors=$3; tx_dropped=$4; tx_carrier=$5; tx_collisions=$6
      getline  # "TX errors:" header line
      getline; tx_err_aborted=$1; tx_err_fifo=$2; tx_err_window=$3; tx_err_heartbeat=$4; tx_err_transns=$5
    }
    END {
      printf "  RX  bytes=%-12s  pkts=%-10s  errors=%-6s  dropped=%-8s  missed=%s\n",
             rx_bytes, rx_packets, rx_errors, rx_dropped, rx_missed
      if (rx_errors+0 > 0)
        printf "      └─ length=%-6s  crc=%-6s  frame=%-6s  fifo=%-6s  missed=%s\n",
               rx_err_length, rx_err_crc, rx_err_frame, rx_err_fifo, rx_err_missed
      printf "  TX  bytes=%-12s  pkts=%-10s  errors=%-6s  dropped=%-8s  carrier=%-6s  collisions=%s\n",
             tx_bytes, tx_packets, tx_errors, tx_dropped, tx_carrier, tx_collisions
      if (tx_errors+0 > 0)
        printf "      └─ aborted=%-6s  fifo=%-6s  window=%-6s  heartbeat=%-6s  transns=%s\n",
               tx_err_aborted, tx_err_fifo, tx_err_window, tx_err_heartbeat, tx_err_transns
    }
  '
  echo ""

  wg show "${iface}" dump | tail -n +2 | while IFS=$'\t' read -r pubkey _preshared endpoint allowed_ips last_handshake rx tx persistent_keepalive; do
    label="${pubkey:0:8}…"

    if [[ "${last_handshake}" == "0" ]]; then
      status="✗ never connected"
    else
      age=$(( now - last_handshake ))
      ago=$(fmt_ago "${last_handshake}")
      if (( age > stale_threshold )); then
        status="⚠ stale   (${ago})"
      else
        status="✔ active  (${ago})"
      fi
    fi

    echo "  peer: ${label}"
    echo "    endpoint:      ${endpoint:-n/a}"
    echo "    allowed_ips:   ${allowed_ips}"
    echo "    handshake:     ${status}"
    printf "    transfer:      rx=%-12s tx=%s\n" "${rx}B" "${tx}B"
    [[ "${persistent_keepalive}" != "off" ]] && echo "    keepalive:     every ${persistent_keepalive}s"
    echo ""
  done
done
