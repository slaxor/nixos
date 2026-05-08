{ ... }:
{

  imports = [
    ./deps.nix
    ./input.nix
    ./keybindings.nix
    ./output.nix
    ./session.nix
    ./window_settings.nix
  ];

  wayland.windowManager.sway = {
    enable = true;
    checkConfig = false;
    wrapperFeatures.gtk = true;
    systemd.variables = [ "--all" ];
    config = {
      defaultWorkspace = "1";
      workspaceLayout = "tabbed";
      fonts.names = [
        "pango:Iosevka Nerd Font Propo Medium 12"
      ];
    };
  };
}
