{ pkgs, ... }:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  imports = [
    ./hardware-configuration.nix
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.slash = import ./home.nix;
  };

  time.timeZone = "Europe/Berlin";

  boot = {
    initrd = {
      availableKernelModules = [
        "nvme"
        "nouveau"
      ];
    };

    kernelPackages = pkgs.linuxPackages_latest;
    blacklistedKernelModules = [
      "dvb_usb_rtl28xxu"
      "dvb_usb_v2"
      "dvb_core"
    ];
    tmp.cleanOnBoot = true;
    kernelParams = [
      # "pcie_aspm=off"
    ];
    loader = {
      systemd-boot.enable = false;
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        devices = [ "nodev" ];
      };
    };
  };

  hardware = {
    enableRedistributableFirmware = true;
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        libva-utils
        rocmPackages.clr
      ];
    };
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];

  hardware = {
    bluetooth.enable = true;
  };

  services = {
    blueman.enable = true;
    udisks2.enable = true;
    udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x14c3", ATTR{device}=="0x0616", RUN+="/bin/sh -c 'echo 1 > /sys/bus/pci/devices/%k/reset'"
      # Keychron K2 HE
      KERNEL=="hidraw*", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0e20", MODE="0660", GROUP="input"
      # Logitech, Inc. Logi Bolt Receiver
      KERNEL=="hidraw*", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c548", MODE="0660", GROUP="input"
    '';
  };

  networking = {
    hostName = "taz";
    usePredictableInterfaceNames = false;
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
        80
        443
      ];
      allowedUDPPorts = [
        53
        68
      ];
      trustedInterfaces = [
        "cilium_host"
        "cilium_net"
        "cilium_vxlan"
        "lxc+"
        "wghare"
      ];
      checkReversePath = false;
    };
    networkmanager = {
      enable = true;
      wifi.powersave = false;
      # dns = "dnsmasq";
    };
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
  };
}
