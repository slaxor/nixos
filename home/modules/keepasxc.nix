{ config, pkgs, ... }:
{
  home.packages = with pkgs; [ keepassxc ];
  systemd.user.services.keepassxc = {
    Unit = {
      Description = "KeePassXC Secret Service";
      After = [
        "graphical-session.target"
        "dbus.service"
      ];
    };
    Service = {
      ExecStart = "${pkgs.keepassxc}/bin/keepassxc --minimized --keyfile ${config.xdg.dataHome}/keepasxc/$USERs-passwords.key ${config.xdg.dataHome}/keepasxc/$USERs-passwords.kdbx";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
