#!/usr/bin/env bash
# shellcheck shell=bash
set -uo pipefail

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  term="$1"
  index="$2"
  gopass_timeout=30
  menu_timeout=60

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
      timeout --kill-after=5 "${menu_timeout}" fuzzel --dmenu --prompt "gopass> " <<<"${matches}"
    fi
  }

  entries="$(timeout --kill-after=5 "${gopass_timeout}" gopass ls --flat)"
  matches="$(grep -F -- "${term}" <<<"${entries}")" || not_found
  entry="$(pick "${matches}")" || exit 0
  [ -n "${entry}" ] || not_found

  timeout --kill-after=5 "${gopass_timeout}" gopass show -o "${entry}"
fi
