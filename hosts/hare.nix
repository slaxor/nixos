{ ... }:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  imports = [
    ./hare-hardware-configuration.nix
    ../modules/docker
  ];

  boot = {
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

  time.timeZone = "Europe/Berlin";
  networking.hostName = "hare";
  services.tmate-ssh-server.host = "hare.t5l.de";
  system.stateVersion = "25.05";
}
