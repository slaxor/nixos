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
    kernelParams = [ "pcie_aspm=off" ];
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

  hardware.enableRedistributableFirmware = true;

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
    '';
  };

  networking = {
    hostName = "kea";
    # nftables = {
    # enable = true;
    # ruleset = ''
    # table inet filter {
    # chain input {
    # type filter hook input priority 0; policy drop;
    # iif lo accept
    # iifname "wghare" accept
    # ct state established,related accept
    # ip protocol icmp accept
    # ip6 nexthdr icmpv6 accept
    # tcp dport 22 accept
    # udp dport 53 accept
    # tcp dport 53 accept
    # udp dport 68 accept
    # tcp dport 68 accept
    # }

    # chain forward {
    # type filter hook forward priority 0; policy accept;
    # }

    # chain output {
    # type filter hook output priority 0; policy accept;
    # }
    # }
    # '';
    firewall = {
      enable = true;
      # backend = "nftables";
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
    # };
    networkmanager = {
      enable = true;
      wifi.powersave = false;
      # dns = "dnsmasq";
    };
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
    extraHosts = ''
      172.18.0.6 api.mgmt.sdc.runs.onstackit.local
      172.18.0.5 idp.mgmt.sdc.runs.onstackit.local
    '';
  };

  # going postal...
  systemd.services.mt7922-pci-reset = {
    description = "PCI reset for MT7922";
    wantedBy = [ "post-resume.target" ];
    after = [ "post-resume.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = ''
        ${pkgs.kmod}/bin/modprobe -r mt7921e
        ${pkgs.coreutils}/bin/echo 1 > /sys/bus/pci/devices/0000:04:00.0/remove
        ${pkgs.coreutils}/bin/sleep 1
        ${pkgs.coreutils}/bin/echo 1 > /sys/bus/pci/rescan
        ${pkgs.kmod}/bin/modprobe mt7921e
      '';
    };
  };

  system.stateVersion = "25.11";
}
