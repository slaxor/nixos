#!/bin/sh
# Puts the sqlite dumps from backup.nix's preHook where the live databases
# belong (borg excludes those). Runs inside the installer after the borg extract.
set -eu

dumps=/mnt/var/lib/borg-sqlite-dumps
storage=/mnt/var/lib/rancher/k3s/storage

target_of() {
  case $1 in
  k3s-state.db) echo /mnt/var/lib/rancher/k3s/server/db/state.db ;;
  *) echo "$storage/$(printf %s "$1" | sed 's|__|/|g')" ;;
  esac
}

for dump in "$dumps"/*; do
  target=$(target_of "$(basename "$dump")")
  mkdir -p "$(dirname "$target")"
  cp -p "$dump" "$target"
  echo "restored: $target"
done
