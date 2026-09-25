#!/usr/bin/env bash
# shellcheck shell=bash
set -uo pipefail

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  term="$1"
  index="$2"

  not_found() {
    echo "[gopass: no entry matching '${term}'${index:+ #${index}}]"
    exit 0
  }

  pick() {
    local matches="$1"
    if [ -n "${index}" ]; then
      sed -n "${index}p" <<<"${matches}"
    elif [ "$(wc -l <<<"${matches}")" -eq 1 ]; then
      echo "${matches}"
    else
      fuzzel --dmenu --prompt "gopass> " <<<"${matches}"
    fi
  }

  entries="$(gopass ls --flat)"
  matches="$(grep -F -- "${term}" <<<"${entries}")" || not_found
  entry="$(pick "${matches}")" || exit 0
  [ -n "${entry}" ] || not_found

  gopass show -o "${entry}"
fi
