{ pkgs, ... }:
{

  sops.secrets.borg-passphrase = { };

  services.borgbackup.jobs.storagebox = {
    paths = [
      "/var/lib/rancher/k3s/storage"
      "/var/lib/rancher/k3s/server/db" # k3s sqlite state
      "/etc/rancher/k3s" # k3s certs + token
    ];

    exclude = [
      "/var/lib/rancher/k3s/storage/pvc-*/.trash*"
    ];

    repo = "ssh://u123456@u123456.your-storagebox.de:23/./borg/hare";

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

    preHook = ''
      # Dump any SQLite databases before borg reads the files
      find /var/lib/rancher/k3s/storage -name '*.db' -o -name '*.sqlite' \
        | while read -r db; do
            ${pkgs.sqlite}/bin/sqlite3 "$db" ".backup ''${db}.borgbackup"
          done
      # k3s state db
      ${pkgs.sqlite}/bin/sqlite3 \
        /var/lib/rancher/k3s/server/db/state.db \
        ".backup /var/lib/rancher/k3s/server/db/state.db.borgbackup"
    '';

    postHook = ''
      find /var/lib/rancher/k3s/storage -name '*.borgbackup' -delete
      rm -f /var/lib/rancher/k3s/server/db/state.db.borgbackup
    '';
  };
}
