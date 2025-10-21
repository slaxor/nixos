{ pkgs, ... }:
{
  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = false;
  services.xserver.desktopManager.gnome.enable = false;
  services.xserver.desktopManager.sway.enable = true;

  programs.sway.enable = true;
  programs.sway.wrapperFeatures.gtk = true;

  # Optional: start Sway automatically on TTY1
  services.getty.autologinUser = "slash";
}
