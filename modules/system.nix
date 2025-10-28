{
  pkgs,
  ...
}:
{
  boot = {
    loader = {
      systemd-boot.enable = false;
      efi.canTouchEfiVariables = true;
    };
    tmp.cleanOnBoot = true;
  };

  networking.networkmanager.enable = true;
  services = {
    resolved.enable = true;
    openssh.enable = true;
    blueman.enable = true;
    udisks2.enable = true;
  };

  hardware.bluetooth.enable = true;

  nix.settings.download-buffer-size = 524288000;
  environment.systemPackages = with pkgs; [
    age
    bash
    bridge-utils
    ctags
    curl
    docker
    fd
    file
    foot
    fzf
    git
    gitui
    gnupg
    gparted
    home-manager
    htop
    hyprpolkitagent
    iotop
    kubectl
    lf
    lshw
    mc
    mtr
    neovim
    neovim-remote
    netcat
    nixfmt-rfc-style
    pciutils
    plocate
    polkit
    ripgrep
    socat
    sops
    sway
    tmux
    tree
    unstable.yazi
    unstable.yaziPlugins.git
    unstable.yaziPlugins.sudo
    unstable.yaziPlugins.ouch
    unstable.yaziPlugins.nord
    unstable.yaziPlugins.lsar
    unstable.yaziPlugins.glow
    unstable.yaziPlugins.diff
    unstable.yaziPlugins.rsync
    unstable.yaziPlugins.piper
    unstable.yaziPlugins.mount
    unstable.yaziPlugins.gitui
    unstable.yaziPlugins.dupes
    unstable.yaziPlugins.chmod
    unstable.yaziPlugins.miller
    unstable.yaziPlugins.duckdb
    unstable.yaziPlugins.bypass
    unstable.yaziPlugins.yatline
    unstable.yaziPlugins.restore
    unstable.yaziPlugins.lazygit
    unstable.yaziPlugins.starship
    unstable.yaziPlugins.projects
    unstable.yaziPlugins.mime-ext
    unstable.yaziPlugins.vcs-files
    unstable.yaziPlugins.no-status
    unstable.yaziPlugins.mediainfo
    unstable.yaziPlugins.toggle-pane
    unstable.yaziPlugins.time-travel
    unstable.yaziPlugins.smart-paste
    unstable.yaziPlugins.smart-enter
    unstable.yaziPlugins.recycle-bin
    unstable.yaziPlugins.full-border
    unstable.yaziPlugins.wl-clipboard
    unstable.yaziPlugins.smart-filter
    unstable.yaziPlugins.rich-preview
    unstable.yaziPlugins.jump-to-char
    unstable.yaziPlugins.yatline-githead
    unstable.yaziPlugins.relative-motions
    unstable.yaziPlugins.yatline-catppuccin
    usbutils
    vimPlugins.yazi-nvim
    vimPlugins.lazy-nvim
    wayland
    wget
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

  security.polkit.adminIdentities = [
    "unix-user:slash"
    "unix-group:wheel"
  ];
  environment.shellAliases = {
    hms =''
      home-manager switch --flake  \$\{HOME}/.config/home-manager#\$\{USER}
    '';
    nors = ''
      sudo nixos-rebuild switch --flake /etc/nixos#\$\{HOSTNAME}
    '';
  };
  # formatter.x86_64-linux = pkgs.nixfmt-rfc-style;
  system.stateVersion = "25.05";
}
