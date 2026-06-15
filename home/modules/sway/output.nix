{ config, ... }:
{
  xdg.configFile."sway/background.jpg".source = ./sway/pingu_oldschool_bg.jpg;

  wayland.windowManager.sway.config.output = {
    "*" = {
      bg = "${config.xdg.configHome}/sway/background.jpg fit";
    };
    "eDP-1" = {
      mode = "2560x1600@165Hz";
      pos = "1270 2160";
      scale = "2.0";
      adaptive_sync = "on";
      transform = "normal";
    };
    "eDP-2" = {
      mode = "2560x1600@165Hz";
      pos = "1270 2160";
      scale = "2.0";
      adaptive_sync = "on";
      transform = "normal";
    };
    "DP-5" = {
      mode = "3840x2160@59Hz";
      pos = "0 0";
      transform = "normal";
    };
  };

  wayland.windowManager.sway.config.bars = [ ];

  wayland.windowManager.sway.extraConfig = ''
    seat "*" xcursor_theme Adwaita 24
  '';
}
