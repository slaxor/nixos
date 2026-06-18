{ ... }:
let
  fonts = {
    gui = {
      # name = "Iosevka Nerd Font Propo Medium";
      name = "FiraCode Nerd Font Propo";
      weight = "Medium";
      size = "12";
    };
    term = {
      name = "FiraCode Nerd Font Mono";
      # name = "Iosevka Nerd Font Mono";
      weight = "Light";
      size = "14";
    };
  };
in
{
  imports = [
    (import ./deps.nix { inherit fonts; })
    ./input.nix
    ./keybindings.nix
    ./output.nix
    ./session.nix
    ./window_settings.nix
    (import ./waybar { inherit fonts; })
  ];
  # 🐧
  wayland.windowManager.sway = {
    enable = true;
    checkConfig = false;
    wrapperFeatures.gtk = true;
    systemd.variables = [ "--all" ];
    config = {
      defaultWorkspace = "1";
      workspaceLayout = "tabbed";
      fonts = {
        names = [ fonts.gui.name ];
        style = fonts.gui.weight;
        size = fonts.gui.size;
      };
    };
  };
}
