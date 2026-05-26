#!/usr/bin/env bash
# shellcheck shell=bash
[ "$(id -u)" -eq 0 ] || exec sudo "${0}" "${@}"

set -euo pipefail
hosts_file="/var/lib/dnsmasq/local.hosts"
touch "${hosts_file}"

help() {
    echo "usage: ${0} add <hostname> <ip-address>"
    echo "       ${0} del <hostname>|<ip-address>"
    echo "       ${0} list"
}

add() {
  [[ ${#} -ne 2 ]] && {
    help
    exit 1
  }
  grep "${2}" "${hosts_file}" && (
    echo "already defined"
    exit 1
  )
  echo "${2} ${1}" >>"${hosts_file}"
  pkill -HUP dnsmasq
  echo "added ${1} -> ${2}"
}

del() {
  [[ ${#} -ne 1 ]] && {
    help
    exit 1
  }
  sed -i -E "/(^${1} | ${1}$)/d" "${hosts_file}"
  pkill -HUP dnsmasq
  echo "removed ${1}"
}

list() {
  cat "${hosts_file}"
}


"${@}"
