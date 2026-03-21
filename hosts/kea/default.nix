{ config, pkgs, ... }:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  imports = [
    ./kea-hardware-configuration.nix
  ];

  time.timeZone = "Europe/Berlin";
  networking.hostName = "kea";

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

  system.stateVersion = "25.05";
}
