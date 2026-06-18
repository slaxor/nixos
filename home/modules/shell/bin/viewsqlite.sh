#!/usr/bin/env bash
# shellcheck shell=bash
set -uo pipefail

db="${1:?echo ${0} <dbfile>}"

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -e
  for t in $(sqlite3 "${db}" .tables); do
    sqlite3 -markdown "${db}" "select * from ${t}; "
  done | glow
fi
