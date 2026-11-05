{ pkgs, ... }:
let
  backupScript = pkgs.writeShellApplication {
    name = "k3s-backup";
    runtimeInputs = [
      pkgs.kubectl
      pkgs.jq
      pkgs.rsync
      pkgs.sqlite
    ];
    text = builtins.readFile ./scripts/k3s-backup.sh;
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
