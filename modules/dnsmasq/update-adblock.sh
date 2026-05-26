#!/usr/bin/env bash
# shellcheck shell=bash
[ "$(id -u)" -eq 0 ] || exec sudo "$0" "$@"
set -euo pipefail

tmp=$(mktemp)
# shellcheck disable=SC2064
trap "rm -f ${tmp}" EXIT

echo "fetching https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts..."
curl -sSfL "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts" >>"${tmp}" ||
  echo "failed: https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"

echo "fetching https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt..."
curl -sSfL "https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt" >>"${tmp}" ||
  echo "failed: https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt"

# normalise: strip comments, blank lines, localhost entries, convert to hosts format
grep -E '^(0\.0\.0\.0|127\.0\.0\.1) ' "${tmp}" |
  grep -v '0\.0\.0\.0 0\.0\.0\.0' |
  grep -v '127\.0\.0\.1 localhost' |
  sed 's/^127\.0\.0\.1/0.0.0.0/' |
  sort -u \
    >/var/lib/dnsmasq/adblock.hosts

pkill -HUP dnsmasq
echo "adblock: $(wc -l </var/lib/dnsmasq/adblock.hosts) entries"
