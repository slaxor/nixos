#!/usr/bin/env bash
# shellcheck shell=bash
set -uo pipefail
backupRoot="/var/lib/syncthing/k3s-backups"

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -e
  mkdir -p "${backupRoot}"
  kubectl get pv -o json |
    jq -r '
            .items[]
            | select(.spec.hostPath != null and .spec.claimRef != null)
            | [
                .spec.hostPath.path,
                .spec.claimRef.namespace,
                .spec.claimRef.name
              ]
            | @tsv
          ' |
    while IFS="$(printf '\t')" read -r pv_path ns pvc; do
      dest="${backupRoot}/${ns}/${pvc}"
      mkdir -p "${dest}/files" "${dest}/sqlite"

      rsync -a --delete "${pv_path}/" "${dest}/files/"

      find "${pv_path}" \
        \( -name '*.db' -o -name '*.sqlite' -o -name '*.sqlite3' \) |
        while read -r db_path; do
          rel="''${db_path#"${pv_path}"/}"
          sqlite3 "${db_path}" ".backup ${dest}/sqlite/''${rel//\//__}" &&
            echo "sqlite ok: ${ns}/${pvc}/${rel}" ||
            echo "sqlite warn: ${ns}/${pvc}/${rel} (locked?)"
        done

      echo "done: ${ns}/${pvc}"
    done
fi
