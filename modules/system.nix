{ pkgs, ... }:
{
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;
  services.resolved.enable = true;

  services.openssh.enable = true;

  nix.settings.download-buffer-size = 524288000;
  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    age
    bash
    ctags
    curl
    curl
    docker
    fd
    foot
    fzf
    git
    gnupg
    gparted
    home-manager
    htop
    hyprpolkitagent
    iotop
    kubectl
    lf
    mc
    mtr
    neovim
    netcat
    nixfmt-rfc-style
    plocate
    polkit
    ripgrep
    socat
    sops
    sway
    tmux
    tree
    wayland
    wget
    yazi
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
    nerd-fonts.iosevka
    nerd-fonts.go-mono
    liberation_ttf
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
  ];

  # formatter.x86_64-linux = pkgs.nixfmt-rfc-style;
  system.stateVersion = "25.05";
}
