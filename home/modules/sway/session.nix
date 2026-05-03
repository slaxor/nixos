{ ... }:

{
  wayland.windowManager.sway.config.startup = [
    # zeal is the only uncommented startup app
    { command = "zeal"; }

    # unclutter hides the mouse cursor when idle
    { command = "unclutter -root -visible"; }
  ];
}
