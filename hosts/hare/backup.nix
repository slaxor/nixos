{ config, pkgs, ... }:
let
  storage-box = "u591925";
  k3s = "${config.services.k3s.package}/bin/k3s";
in
{
  sops.secrets.borg-passphrase = { };

  systemd.tmpfiles.rules = [
    "d /var/lib/borg-sqlite-dumps 0700 root root -"
    "d /var/lib/borg-k3s-images 0700 root root -"
    "d /var/lib/borg-pvc-copies 0700 root root -"
  ];

  systemd.services.borgbackup-job-storagebox.onFailure = [ "notify-failure@%n.service" ];

  services.borgbackup.jobs.storagebox = {
    repo = "ssh://${storage-box}@${storage-box}.your-storagebox.de:23/./borg/hare";
    extraArgs = [
      "--lock-wait"
      "3600"
    ];

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
      "/var/lib/rancher/k3s/server/token"
      "/etc/rancher/k3s"
      "/var/lib/borg-sqlite-dumps"
      "/var/lib/borg-k3s-images"
      "/var/lib/borg-pvc-copies"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
      "/etc/wireguard/peers"
      "/etc/shadow"
      "/var/lib/nixos"
      "/home"
    ];

    exclude = [
      "sh:/var/lib/rancher/k3s/server/db/state.db*"
      "sh:/var/lib/rancher/k3s/storage/**/*.db"
      "sh:/var/lib/rancher/k3s/storage/**/*.db-*"
      "sh:/var/lib/rancher/k3s/storage/**/*.sqlite"
      "sh:/var/lib/rancher/k3s/storage/**/*.sqlite-*"
      "sh:/var/lib/rancher/k3s/storage/**/*.sqlite3"
      "sh:/var/lib/rancher/k3s/storage/**/*.sqlite3-*"
    ];

    readWritePaths = [
      "/var/lib/borg-sqlite-dumps"
      "/var/lib/borg-k3s-images"
      "/var/lib/borg-pvc-copies"
      "/var/lib/rancher/k3s/server/db"
      "/var/lib/rancher/k3s/storage"
    ];
    preHook = ''
      dump_sqlite() {
        ${pkgs.sqlite}/bin/sqlite3 -cmd ".timeout 10000" "$1" ".backup $2" \
          && echo "sqlite ok: $1"
      }

      export_images() {
        local dir=$1 refs ref name exported=0 skipped=0
        rm -f "$dir"/*.tar
        refs=$(${k3s} ctr -n k8s.io images list -q | grep -v '^sha256:')
        for ref in $refs; do
          name=$(printf %s "$ref" | tr '/:@' '___')
          if ${k3s} ctr -n k8s.io images export --platform linux/amd64 "$dir/$name.tar" "$ref"; then
            exported=$((exported + 1))
          else
            echo "image skipped: $ref"
            rm -f "$dir/$name.tar"
            skipped=$((skipped + 1))
          fi
        done
        echo "images: $exported exported, $skipped skipped"
      }

      # deployments labelled m11s.de/backup=stop hold databases that are not
      # consistent while open (rocksdb): scale to 0, copy their PVCs, scale back
      wait_scaled_down() {
        local ns=$1 name=$2
        for _ in $(seq 60); do
          [ -z "$(${k3s} kubectl -n "$ns" get deploy "$name" -o jsonpath='{.status.replicas}')" ] && return 0
          sleep 2
        done
        echo "timeout scaling down $ns/$name"
        return 1
      }

      copy_stopped() {
        local dir=$1 ns name replicas rc
        find "$dir" -mindepth 1 -delete
        ${k3s} kubectl get deploy -A -l m11s.de/backup=stop \
          -o jsonpath='{range .items[*]}{.metadata.namespace} {.metadata.name} {.spec.replicas}{"\n"}{end}' \
          | while read -r ns name replicas; do
              rc=0
              ${k3s} kubectl -n "$ns" scale deploy "$name" --replicas=0
              wait_scaled_down "$ns" "$name" \
                && cp -a /var/lib/rancher/k3s/storage/*_"$ns"_* "$dir/" \
                || rc=1
              ${k3s} kubectl -n "$ns" scale deploy "$name" --replicas="$replicas"
              [ "$rc" = 0 ] && echo "pvc copy ok: $ns/$name" || exit 1
            done
      }

      mkdir -p /var/lib/borg-sqlite-dumps
      rm -f /var/lib/borg-sqlite-dumps/*

      find /var/lib/rancher/k3s/storage \
        \( -name '*.db' -o -name '*.sqlite' -o -name '*.sqlite3' \) \
        | while read -r db; do
            dest=$(echo "$db" | sed 's|/var/lib/rancher/k3s/storage/||;s|/|__|g')
            dump_sqlite "$db" "/var/lib/borg-sqlite-dumps/$dest" || exit 1
          done

      dump_sqlite /var/lib/rancher/k3s/server/db/state.db /var/lib/borg-sqlite-dumps/k3s-state.db
      export_images /var/lib/borg-k3s-images
      copy_stopped /var/lib/borg-pvc-copies
    '';

    postHook = "";
  };
}
