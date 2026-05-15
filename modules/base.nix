{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    bash
    binutils
    borgbackup
    borgmatic
    curl
    dialog
    efibootmgr
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
    unstable.partclone
    unstable.partclone-utils
    psmisc
    ripgrep
    socat
    terminus_font
    tmux
    tree
    unixtools.xxd
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
    nix-ld.enable = true;
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
  };

  services = {
    envfs.enable = true;
    dbus.enable = true;
    locate = {
      enable = true;
      package = pkgs.plocate;
    };
    fwupd.enable = true;
    journald.extraConfig = ''
      SystemMaxUse=500M
      SystemMaxFileSize=50M
      MaxFileSec=1week
    '';
  };

  security = {
    polkit.enable = true;
    sudo.extraConfig = ''
      Defaults timestamp_timeout=480
    '';
  };

  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-132n.psf.gz";
    packages = with pkgs; [ terminus_font ];
    keyMap = "us";
  };
  system.stateVersion = "25.11";
}
