{ config, pkgs, ... }:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  imports = [
    ./taz-hardware-configuration.nix
  ];

  time.timeZone = "Europe/Berlin";
  networking.hostName = "taz";

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      # grub = {
      # enable = true;
      # devices = [ "nodev" ];
      # };
    };

    initrd.availableKernelModules = [
      "nvme"
      "nouveau"
    ];
  };

  services.tmate-ssh-server.host = "taz.slaxor.de";

  system.stateVersion = "25.05";
}
