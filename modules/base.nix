{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    bash
    binutils
    curl
    dialog
    gcc
    git
    git-filter-repo
    gptfdisk
    home-manager
    htop
    iotop
    lf
    lsb-release
    lsof
    lvm2
    gnumake
    mc
    psmisc
    ripgrep
    socat
    terminus_font
    tmux
    tree
    wget
    neovim
    neovim-remote
    unixtools.xxd
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  virtualisation.docker.enable = true;
  nix.settings.download-buffer-size = 524288000;
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    blacklistedKernelModules = [
      "dvb_usb_rtl28xxu"
      "dvb_usb_v2"
      "dvb_core"
    ];
    tmp.cleanOnBoot = true;
  };
  i18n.defaultLocale = "C.UTF-8";
  i18n.extraLocaleSettings = {
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

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024; # 16 GB
    }
  ];

  hardware = {
    bluetooth.enable = true;
    # rtl-sdr.enable = true;
  };

  programs = {
    nix-ld.enable = true;
    # lxqt.polkit.enable = true;
    # mtr.enable = true;
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
    blueman.enable = true;
    locate = {
      enable = true;
      package = pkgs.plocate;
    };
    udisks2.enable = true;
  };

  security.polkit.enable = true;

  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-132n.psf.gz";
    packages = with pkgs; [ terminus_font ];
    keyMap = "us";
  };
}
