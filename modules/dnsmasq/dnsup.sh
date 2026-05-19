#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail

add() {
  [[ $# -ne 2 ]] && {
    echo "usage: dnsup <hostname> <ip>"
    exit 1
  }
  echo "$2  $1" >>/var/lib/dnsmasq/local.hosts
}

del() {
  echo "$1 -> $2"
  [[ $# -ne 1 ]] && {
    echo "usage: dns-rm <hostname>"
    exit 1
  }
  sed -i "/ $1$/d" /var/lib/dnsmasq/local.hosts
  pkill -HUP dnsmasq
  echo "removed $1"
}

list() {
  cat /var/lib/dnsmasq/local.hosts
}

"$@"
