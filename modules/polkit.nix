{ config, pkgs, ... }:
{
  # environment.systemPackages = with pkgs; [
  # ];

  security.polkit.adminIdentities = [
    "unix-user:slash"
    "unix-group:wheel"
  ];

  security.polkit = {
    extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (
          subject.isInGroup("users")
            && (
              action.id == "org.freedesktop.login1.reboot" ||
              action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
              action.id == "org.freedesktop.login1.power-off" ||
              action.id == "org.freedesktop.login1.power-off-multiple-sessions"
            )
          )
        {
          return polkit.Result.YES;
        }
      });
      polkit.addRule(function(action, subject) {
          if (action.id == "org.gnome.gparted" &&
              subject.isInGroup("wheel")) {
              return polkit.Result.YES;
          }
      });
    '';
  };
}
