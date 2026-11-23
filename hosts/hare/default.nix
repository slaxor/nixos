{ pkgs, ... }:
let
  hare = import ./address.nix;
in
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  imports = [
    ./hare-hardware-configuration.nix
    ./networking.nix
    ./backup.nix
    ./notify.nix
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.slash = import ./home.nix;
  };

  time.timeZone = "Europe/Berlin";

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.enable = false;
      efi.canTouchEfiVariables = false;
      grub = {
        enable = true;
        devices = [ "/dev/nvme0n1" ];
      };
    };
    initrd.network = {
      enable = true;
      ssh = {
        enable = true;
        port = 2222;
        authorizedKeys = import ../../users/slash-keys.nix;
        hostKeys = [ "/etc/ssh/ssh_host_ed25519_key" ];
      };
    };

    initrd.availableKernelModules = [
      "nvme"
      "e1000e"
      "r8169"
    ];
    kernelParams = [ "ip=dhcp" ];
  };

  boot.kernelModules = [
    "br_netfilter"
    "overlay"
    "iptable_nat"
    "iptable_filter"
  ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.bridge.bridge-nf-call-iptables" = 1;
  };

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  };

  # environment.etc."update-motd.d/10-custom".text = ''
  # '';
  programs.bash.loginShellInit = ''
    #!/usr/bin/env bash
    fastfetch
    # kubefetch
  '';
  # security.pam.services.sshd.text = ''
  # session optional pam_motd.so motd=/etc/motd
  # '';
  # environment.etc."motd".text = ''
  # Welcome to hare.t5l.de

  # '';

  networking.hostName = "hare";
  services = {
    openssh = {
      enable = true;
      listenAddresses = [
        {
          addr = hare.ipv4.address;
          port = 22;
        }
        {
          addr = hare.ipv6.address;
          port = 22;
        }
      ];
    };
  };
  system.stateVersion = "26.05";
}
