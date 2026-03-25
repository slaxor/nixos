{ lib, ... }:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  imports = [
    ./kea-hardware-configuration.nix
  ];

  time.timeZone = "Europe/Berlin";

  boot = {
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

  networking = {
    hostName = "kea";
    nftables = {
      enable = true;
      ruleset = ''
        table inet filter {
          chain input {
            type filter hook input priority 0; policy drop;
            iif lo accept
            iifname "wghare" accept
            ct state established,related accept
            ip protocol icmp accept
            ip6 nexthdr icmpv6 accept
            tcp dport 22 accept
            udp dport 53 accept
            tcp dport 53 accept
            udp dport 68 accept
            tcp dport 68 accept
          }

          chain forward {
            type filter hook forward priority 0; policy accept;
          }

          chain output {
            type filter hook output priority 0; policy accept;
          }
        }
      '';
    };
    networkmanager = {
      enable = true;
      wifi.powersave = false;
    };
  };

  # if the normal stuff doesn't work
  # systemd.services.mt7922-reset = {
  # description = "Reset MT7922 WiFi on resume";
  # wantedBy = [ "suspend.target" ];
  # after = [ "suspend.target" ];
  # serviceConfig = {
  # Type = "oneshot";
  # ExecStart = ''
  # ${pkgs.coreutils}/bin/sleep 2
  # ${pkgs.kmod}/bin/modprobe -r mt7921e
  # ${pkgs.kmod}/bin/modprobe mt7921e
  # '';
  # };

  # going postal...
  # systemd.services.mt7922-pci-reset = {
  # description = "PCI reset for MT7922";
  # wantedBy = [ "post-resume.target" ];
  # after = [ "post-resume.target" ];
  # serviceConfig = {
  # Type = "oneshot";
  # ExecStart = ''
  # echo 1 > /sys/bus/pci/devices/0000:04:00.0/remove
  # sleep 1
  # echo 1 > /sys/bus/pci/rescan
  # '';
  # };
  # };
  # };

  system.stateVersion = "25.11";
}
