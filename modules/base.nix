{ pkgs, ... }:
{
  imports = [
    ./storage.nix
  ];

  environment.systemPackages = with pkgs; [
    bash
    binutils
    borgbackup
    borgmatic
    curl
    dialog
    efibootmgr
    fastfetch
    gcc
    git
    git-filter-repo
    gnumake
    gptfdisk
    home-manager
    htop
    iotop
    lf
    lsb-release
    lsof
    lvm2
    mc
    neovim
    neovim-remote
    net-tools
    parted
    partclone
    partclone-utils
    psmisc
    ripgrep-all
    vgrep
    socat
    terminus_font
    tmux
    tree
    unixtools.xxd
    vorta
    wget
  ];

  hardware = {
    firmware = [ pkgs.linux-firmware ];
  };

  i18n = {
    defaultLocale = "C.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "de_DE.UTF-8";
      LC_IDENTIFICATION = "de_DE.UTF-8";
      LC_MEASUREMENT = "de_DE.UTF-8";
      LC_MONETARY = "de_DE.UTF-8";
      LC_NAME = "de_DE.UTF-8";
      LC_NUMERIC = "de_DE.UTF-8";
      LC_PAPER = "de_DE.UTF-8";
      LC_TELEPHONE = "de_DE.UTF-8";
      LC_TIME = "de_DE.UTF-8";
    };
  };

  programs = {
    fuse.userAllowOther = true;

    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };

    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 14d --keep 8";
      flake = "$HOME/git/github.com/slaxor/nixos#$HOSTNAME";
    };

    nix-ld.enable = true;
  };

  nix = {
    settings = {
      download-buffer-size = 524288000;
    };

    # gc = {
    # automatic = true;
    # dates = "weekly";
    # options = "--delete-older-than 30d";
    # };
  };

  services = {
    envfs.enable = true;
    dbus.enable = true;
    locate = {
      enable = true;
      package = pkgs.plocate;
    };
    fwupd.enable = true;
    # journald.settings.Journal = {
    # SystemMaxUse = "1G";
    # SystemMaxFileSize = "50M";
    # MaxFileSec = "1month";
    # MaxRetentionSec = "1month";
    # };
  };

  boot.kernel.sysctl."kernel.dmesg_restrict" = 0;

  security = {
    polkit.enable = true;
    sudo = {
      enable = true;
      extraConfig = ''
        Defaults timestamp_timeout=480
        Defaults env_keep += "SYSTEMD_PAGER"
      '';
      extraRules = [
        {
          users = [ "slash" ];
          commands = [
            {
              command = "/run/current-system/sw/bin/dmesg -w";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];
    };
  };

  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-132n.psf.gz";
    packages = with pkgs; [ terminus_font ];
    keyMap = "us";
  };

  system.stateVersion = "26.05";
}
