{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    bash
    curl
    git
    gptfdisk
    htop
    iotop
    lf
    lsb-release
    lsof
    lvm2
    gnumake
    mc
    ripgrep
    socat
    tmux
    tree
    wget
    neovim
    neovim-remote
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  virtualisation.docker.enable = true;


  nix.settings.download-buffer-size = 524288000;
  boot = {
    loader = {
      systemd-boot.enable = false;
      grub = {
        enable = true;
        efiSupport = true;
        enableCryptodisk = true;
        device = "nodev";
      };
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    tmp.cleanOnBoot = true;
  };
  i18n.defaultLocale = "de_DE.UTF-8";
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

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 16*1024; # 16 GB
  }];

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
    blueman.enable = true;
    locate = {
      enable = true;
      package = pkgs.plocate;
    };
    printing.enable = true;
    udisks2.enable = true;
  };

  security.polkit.enable = true;

  console = {
    font = "solar24x23";
    keyMap = "us";
  };
}
