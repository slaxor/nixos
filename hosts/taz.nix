{ ... }:
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

  system.stateVersion = "25.11";
}
