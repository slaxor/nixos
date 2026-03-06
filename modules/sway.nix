{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    sway
    swaylock-effects
    wayland
    foot
    gparted
    xdg-desktop-portal-wlr
    adwaita-icon-theme
  ];

  hardware.graphics.enable32Bit = true;

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      swaylock
      swayidle
      wl-clipboard
      wf-recorder
      mako
      grim
      kanshi
      slurp
      alacritty
      wofi
    ];
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export _JAVA_AWT_WM_NONREPARENTING=1
      export MOZ_ENABLE_WAYLAND=1
    '';
  };
  services.xserver = {
    enable = true;
    # displayManager.sddm.enable = false;
    # desktopManager.gnome.enable = false;
    # desktopManager.sway.enable = true;
    # displayManager.sessionCommands = "xhost +local:";
  };

  services.gvfs.enable = true;
  systemd.services = {
    dconf = {
      enable = true;
      serviceConfig.ExecStart = ''
        # Example of setting up a dconf database path or other initialization
        mkdir -p /etc/dconf/db && touch /etc/dconf/db/local
        dconf update
      '';
    };
  };
}
