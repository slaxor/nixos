#!/bin/sh
# Puts the sqlite dumps from backup.nix's preHook where the live databases
# belong (borg excludes those). Runs inside the installer after the borg extract.
set -eu

dumps=/mnt/var/lib/borg-sqlite-dumps
storage=/mnt/var/lib/rancher/k3s/storage

target_of() {
  case ${1} in
  k3s-state.db) echo /mnt/var/lib/rancher/k3s/server/db/state.db ;;
  *)
    relative=$(printf %s "${1}" | sed 's|__|/|g')
    echo "${storage}/${relative}"
    ;;
  esac
}

for dump in "${dumps}"/*; do
  name=$(basename "${dump}")
  target=$(target_of "${name}")
  target_dir=$(dirname "${target}")
  mkdir -p "${target_dir}"
  cp -p "${dump}" "${target}"
  echo "restored: ${target}"
done
