{ pkgs, ... }:
let
  backupRoot = "/var/lib/syncthing/k3s-backups";

  backupScript = pkgs.writeShellApplication {
    name = "k3s-backup";
    runtimeInputs = [
      pkgs.kubectl
      pkgs.jq
      pkgs.rsync
      pkgs.sqlite
    ];
    text = ''
      mkdir -p "${backupRoot}"

      kubectl get pv -o json \
        | jq -r '
            .items[]
            | select(.spec.hostPath != null and .spec.claimRef != null)
            | [
                .spec.hostPath.path,
                .spec.claimRef.namespace,
                .spec.claimRef.name
              ]
            | @tsv
          ' \
        | while IFS="$(printf '\t')" read -r pv_path ns pvc; do
            dest="${backupRoot}/$ns/$pvc"
            mkdir -p "$dest/files" "$dest/sqlite"

            rsync -a --delete "$pv_path/" "$dest/files/"

            find "$pv_path" \
              \( -name '*.db' -o -name '*.sqlite' -o -name '*.sqlite3' \) \
              | while read -r db_path; do
                  rel="''${db_path#"$pv_path"/}"
                  sqlite3 "$db_path" ".backup $dest/sqlite/''${rel//\//__}" \
                    && echo "sqlite ok: $ns/$pvc/$rel" \
                    || echo "sqlite warn: $ns/$pvc/$rel (locked?)"
                done

            echo "done: $ns/$pvc"
          done
    '';
  };
in
{
  systemd.services.k3s-backup = {
    description = "k3s PVC backup";
    after = [ "k3s.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${backupScript}/bin/k3s-backup";
      User = "root";
    };
  };

  systemd.timers.k3s-backup = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };
}
