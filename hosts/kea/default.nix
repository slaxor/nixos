{ pkgs, ... }:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  imports = [
    ./hardware-configuration.nix
  ];

  time.timeZone = "Europe/Berlin";

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    blacklistedKernelModules = [
      "dvb_usb_rtl28xxu"
      "dvb_usb_v2"
      "dvb_core"
    ];
    tmp.cleanOnBoot = true;
    kernelParams = [
      # "pcie_aspm=off"
      "mt7921e.disable_aspm=1"
    ];
    loader = {
      systemd-boot.enable = false;
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        devices = [ "nodev" ];
      };
    };

    initrd.availableKernelModules = [
      "nvme"
      "amdgpu"
    ];
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
      # Framework Laptop 16 Keyboard Module - ANS
      KERNEL=="hidraw*", ATTRS{idVendor}=="32ac", ATTRS{idProduct}=="0012", MODE="0660", GROUP="input"
      # Framework Laptop 16 RGB Macropad
      KERNEL=="hidraw*", ATTRS{idVendor}=="32ac", ATTRS{idProduct}=="0013", MODE="0660", GROUP="input"
      # Keychron K2 HE
      KERNEL=="hidraw*", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0e20", MODE="0660", GROUP="input"
      # Logitech, Inc. Logi Bolt Receiver
      KERNEL=="hidraw*", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c548", MODE="0660", GROUP="input"
    '';
  };

  networking = {
    hostName = "kea";
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
      dns = "none";
    };
  };

  systemd = {
    services = {
      systemd-journald.serviceConfig.WatchdogSec = "10min";
    };
    # going postal...
    # mt7922-pci-reset = {
    # description = "PCI reset for MT7922";
    # wantedBy = [ "post-resume.target" ];
    # after = [ "post-resume.target" ];
    # serviceConfig = {
    # Type = "oneshot";
    # ExecStart = ''
    # if ! ${pkgs.iw}/bin/iw dev | grep -q Interface; then
    # ${pkgs.kmod}/bin/modprobe -r mt7921e
    # ${pkgs.coreutils}/bin/echo 1 > /sys/bus/pci/devices/0000:04:00.0/remove
    # ${pkgs.coreutils}/bin/sleep 2
    # ${pkgs.coreutils}/bin/echo 1 > /sys/bus/pci/rescan
    # ${pkgs.coreutils}/bin/sleep 3
    # ${pkgs.kmod}/bin/modprobe mt7921e
    # ${pkgs.coreutils}/bin/sleep 3
    # ${pkgs.networkmanager}/bin/nmcli radio wifi off
    # ${pkgs.networkmanager}/bin/nmcli radio wifi on
    # fi
    # '';
    # };
    # };

    # timers.mt7922-pci-reset = {
    # description = "Periodically check MT7922 wifi";
    # wantedBy = [ "timers.target" ];
    # timerConfig = {
    # OnBootSec = "30s"; # first run 30s after boot
    # OnUnitActiveSec = "5m"; # then every 5 minutes
    # Unit = "mt7922-pci-reset.service";
    # };
    # };
  };
}
