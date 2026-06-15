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

# normalise + sanitize: hosts format, one valid name per line
awk '
  /^(0\.0\.0\.0|127\.0\.0\.1)[ \t]/ {
    name = tolower($2)
    if (name == "0.0.0.0" || name == "localhost") next
    if (name ~ /^([a-z0-9_]([a-z0-9_-]{0,61}[a-z0-9_])?\.)+[a-z0-9_]([a-z0-9_-]{0,61}[a-z0-9_])?$/ \
        && length(name) <= 253) {
      print "0.0.0.0 " name
      next
    }
    rejected++
    print "rejected: " $0 > "/dev/stderr"
  }
  END { if (rejected) print rejected " lines rejected" > "/dev/stderr" }
' "${tmp}" | sort -u >/var/lib/dnsmasq/adblock.hosts

pkill -HUP dnsmasq
echo "adblock: $(wc -l </var/lib/dnsmasq/adblock.hosts) entries"
