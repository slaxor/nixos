{ ... }:

{
  wayland.windowManager.sway.config.startup = [
    { command = "zeal"; }
    { command = "nm-applet"; }
    { command = "blueman-applet"; }
    { command = "unclutter -root -visible"; }
  ];
}
