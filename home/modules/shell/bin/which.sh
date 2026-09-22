#!/usr/bin/env bash
# shellcheck shell=bash
set -uo pipefail

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -e
  target=$1
  verbose=0
  [[ -t 1 ]] && verbose=1

  if ! resolved=$(which "${target}"); then
    [[ ${verbose} -eq 1 ]] && echo "which: no ${target} found on PATH" >&2
    exit 1
  fi

  if [[ ${verbose} -eq 1 ]]; then
    echo "which: ${resolved}" >&2
    stage=${resolved}
    while [ -L "${stage}" ]; do
      link=$(readlink "${stage}")
      case ${link} in
      /*) next=${link} ;;
      *) next=$(dirname "${stage}")/${link} ;;
      esac
      echo "  -> ${next}" >&2
      stage=${next}
    done
  fi

  realpath "${resolved}"
fi
