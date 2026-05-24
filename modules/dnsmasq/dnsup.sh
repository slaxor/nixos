#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail
hosts_file="/var/lib/dnsmasq/local.hosts"
touch "${hosts_file}"

add() {
  [[ $# -ne 2 ]] && {
    echo "usage: dnsup <hostname> <ip>"
    exit 1
  }
  grep "${2}" "${hosts_file}" && (
    echo "already defined"
    exit 1
  )
  echo "$2 $1" >>"${hosts_file}"
}

del() {
  [[ $# -ne 1 ]] && {
    echo "usage: ${0} del <hostname>|<ip-address>"
    exit 1
  }
  sed -i -E "/(^$1 | $1$)/d" "${hosts_file}"
  pkill -HUP dnsmasq
  echo "removed $1"
}

list() {
  cat "${hosts_file}"
}

"$@"
