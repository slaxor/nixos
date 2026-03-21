{ ... }:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  imports = [
    ./taz-hardware-configuration.nix
    ./users/slash.nix
    ./users/stackit.nix
  ];

  time.timeZone = "Europe/Berlin";
  networking.hostName = "taz";

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
  };

  system.stateVersion = "25.11";
}
