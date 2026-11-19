#!/bin/sh
# Puts the consistent sqlite dumps from backup.nix's preHook over the live
# copies borg grabbed. Runs inside the installer after the borg extract to /mnt.
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
  cp -p "$dump" "$target"
  rm -f "$target-wal" "$target-shm"
  echo "restored: $target"
done
