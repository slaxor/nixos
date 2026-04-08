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
    loader = {
      systemd-boot = {
        consoleMode = "1";
        enable = true;
        configurationLimit = 10;
      };
      efi.canTouchEfiVariables = true;
    };

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
    kernelParams = [ "pcie_aspm=off" ];
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
    hostName = "taz";
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
    networkmanager = {
      enable = true;
      wifi.powersave = false;
      # dns = "dnsmasq";
    };
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
    # extraHosts = ''
    # 172.18.0.6 api.mgmt.sdc.runs.onstackit.local
    # 172.18.0.5 idp.mgmt.sdc.runs.onstackit.local
    # '';
  };
  system.stateVersion = "25.11";
}
