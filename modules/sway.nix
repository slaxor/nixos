{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    xdg-desktop-portal-wl
  ];
  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = false;
  services.xserver.desktopManager.gnome.enable = false;
  services.xserver.desktopManager.sway.enable = true;
  services.xserver.displayManager.sessionCommands = "xhost +local:"

  programs.sway.enable = true;
  programs.sway.wrapperFeatures.gtk = true;

  # Optional: start Sway automatically on TTY1
  services.getty.autologinUser = "slash";
}
