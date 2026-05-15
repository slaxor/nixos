{ pkgs, ... }:
let
  storage-box = "u591925";
in
{
  sops.secrets.borg-passphrase = { };

  systemd.tmpfiles.rules = [
    "d /var/lib/borg-sqlite-dumps 0700 root root -"
  ];

  services.borgbackup.jobs.storagebox = {
    repo = "ssh://${storage-box}@${storage-box}.your-storagebox.de:23/./borg/hare";

    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat /run/secrets/borg-passphrase"; # your secret manager path
    };

    environment = {
      BORG_RSH = "ssh -i /root/.ssh/borg_hetzner -p 23 -o StrictHostKeyChecking=accept-new";
    };

    compression = "auto,zstd";

    startAt = "daily";

    prune.keep = {
      daily = 7;
      weekly = 4;
      monthly = 6;
    };

    paths = [
      "/var/lib/rancher/k3s/storage"
      "/var/lib/rancher/k3s/server/db"
      "/etc/rancher/k3s"
      "/var/lib/borg-sqlite-dumps"
    ];

    exclude = [
      "sh:/var/lib/rancher/k3s/storage/**/*.db-shm"
      "sh:/var/lib/rancher/k3s/storage/**/*.db-wal"
    ];

    readWritePaths = [ "/var/lib/borg-sqlite-dumps" ];
    preHook = ''
      mkdir -p /var/lib/borg-sqlite-dumps
      rm -f /var/lib/borg-sqlite-dumps/*

      find /var/lib/rancher/k3s/storage \
        \( -name '*.db' -o -name '*.sqlite' -o -name '*.sqlite3' \) \
        | while read -r db; do
            dest=$(echo "$db" | sed 's|/var/lib/rancher/k3s/storage/||;s|/|__|g')
            ${pkgs.sqlite}/bin/sqlite3 "$db" ".backup /var/lib/borg-sqlite-dumps/$dest" \
              && echo "sqlite ok: $db" \
              || echo "sqlite warn: $db (locked, using live file)"
          done

      ${pkgs.sqlite}/bin/sqlite3 \
        /var/lib/rancher/k3s/server/db/state.db \
        ".backup /var/lib/borg-sqlite-dumps/k3s-state.db" \
        || echo "sqlite warn: k3s state.db locked"
    '';

    postHook = "";
  };
}
