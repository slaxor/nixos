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

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 16*1024; # 16 GB
  }];

  networking.networkmanager.enable = true;
  services = {
    resolved.enable = true;
    openssh = {
      enable = true;
      settings.KbdInteractiveAuthentication = false;
    };
    blueman.enable = true;

    udisks2.enable = true;
  };

  hardware = {
    bluetooth.enable = true;
    rtl-sdr.enable = true;
  };

  nix.settings.download-buffer-size = 524288000;
  environment.systemPackages = with pkgs; [
    age
    bash
    bc
    bcachefs-tools
    bridge-utils
    coreutils
    ctags
    curl
    dconf
    docker
    exfat
    f2fs-tools
    fd
    fdupes
    file
    firmware-manager
    firmware-updater
    foot
    fzf
    git
    gitui
    gnupg
    gparted
    gptfdisk
    home-manager
    htop
    hyprpolkitagent
    iotop
    kubectl
    kubebuilder
    kubernetes-kcp
    lf
    lsb-release
    lshw
    lsof
    lvm2
    gnumake
    mc
    mtr
    ncdu
    neovim
    neovim-remote
    netcat
    nixfmt-rfc-style
    ntfs3g
    pango
    pciutils
    plocate
    polkit
    ripgrep
    shellcheck
    socat
    sops
    sway
    swaylock-effects
    tmux
    tree
    udftools
    unstable.yazi
    unstable.yaziPlugins.bypass
    unstable.yaziPlugins.chmod
    unstable.yaziPlugins.diff
    unstable.yaziPlugins.duckdb
    unstable.yaziPlugins.dupes
    unstable.yaziPlugins.full-border
    unstable.yaziPlugins.git
    unstable.yaziPlugins.gitui
    unstable.yaziPlugins.glow
    unstable.yaziPlugins.jump-to-char
    unstable.yaziPlugins.lazygit
    unstable.yaziPlugins.lsar
    unstable.yaziPlugins.mediainfo
    unstable.yaziPlugins.miller
    unstable.yaziPlugins.mime-ext
    unstable.yaziPlugins.mount
    unstable.yaziPlugins.no-status
    unstable.yaziPlugins.nord
    unstable.yaziPlugins.ouch
    unstable.yaziPlugins.piper
    unstable.yaziPlugins.projects
    unstable.yaziPlugins.recycle-bin
    unstable.yaziPlugins.relative-motions
    unstable.yaziPlugins.restore
    unstable.yaziPlugins.rich-preview
    unstable.yaziPlugins.rsync
    unstable.yaziPlugins.smart-enter
    unstable.yaziPlugins.smart-filter
    unstable.yaziPlugins.smart-paste
    unstable.yaziPlugins.starship
    unstable.yaziPlugins.sudo
    unstable.yaziPlugins.time-travel
    unstable.yaziPlugins.toggle-pane
    unstable.yaziPlugins.vcs-files
    unstable.yaziPlugins.wl-clipboard
    unstable.yaziPlugins.yatline
    unstable.yaziPlugins.yatline-catppuccin
    unstable.yaziPlugins.yatline-githead
    usbutils
    vimPlugins.lazy-nvim
    vimPlugins.yazi-nvim
    wayland
    wget
  ];

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.droid-sans-mono
      nerd-fonts.iosevka
      nerd-fonts.go-mono
      liberation_ttf
      mplus-outline-fonts.githubRelease
      dina-font
      proggyfonts
    ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  programs = {
    nix-ld.enable = true;
    ssh = {
      startAgent = true;
      enableAskPassword = true;
    };
  };

  security.polkit.adminIdentities = [
    "unix-user:slash"
    "unix-group:wheel"
  ];

  environment.shellAliases = {
    hms =''
      home-manager switch --flake  $HOME/.config/home-manager#$USER
    '';
    nors = ''
      sudo nixos-rebuild switch --flake /etc/nixos#$HOSTNAME
    '';
  };

  environment.binsh = "${pkgs.bashInteractive}/bin/bash";
  environment.pathsToLink = [ "/bin" ];

  systemd.services.dconf = {
    enable = true;
    serviceConfig.ExecStart = ''
      # Example of setting up a dconf database path or other initialization
      mkdir -p /etc/dconf/db && touch /etc/dconf/db/local
      dconf update
    '';
  };




  # environment."bin/true".source = "${pkgs.coreutils}/bin/true";

  # environment.etc = {

    # "polkit-1/rules.d/90-org-firmware-manager.rules" = {
      # source = pkgs.writeText "firmware-manager-polkit-rule" ''
        # polkit.addRule(function(action, subject) {
            # if (action.id.indexOf("org.freedesktop.fwupd.") === 0 && subject.isInGroup("wheel")) {
                # return polkit.Result.YES;
            # }
        # });
      # '';
    # };
  # };

  # formatter.x86_64-linux = pkgs.nixfmt-rfc-style;
  system.stateVersion = "25.05";
}
