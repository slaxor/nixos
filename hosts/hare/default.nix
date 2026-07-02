{ pkgs, ... }:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  imports = [
    ./hare-hardware-configuration.nix
    ./networking.nix
    ./backup.nix
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
        authorizedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOtjkbH0TGABWHHuV5Rrzt0UIKJBkPIo8tHXHoyC9kBT slash@kea"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMofo4uP8iGMw2R1LFzBQu7TuiSqwS28ILf1L1Mx/xGx slash@taz"
        ];
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
          addr = "144.76.195.142";
          port = 22;
        }
        {
          addr = "2a01:4f8:200:7181::1";
          port = 22;
        }
      ];
    };
    tmate-ssh-server.host = "hare.t5l.de";
  };
  system.stateVersion = "26.05";
}
