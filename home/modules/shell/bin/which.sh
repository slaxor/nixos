#!/usr/bin/env bash
# shellcheck shell=bash
set -uo pipefail

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -e
  target=$1
  resolved=$(which "${target}")

  if fn=$(declare -f "${target}"); then
    echo "func: ${fn}" >&2
  fi

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

  realpath "${resolved}"
fi
