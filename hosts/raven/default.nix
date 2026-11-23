{ ... }:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "raven";
  time.timeZone = "Europe/Berlin";

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  services.displayManager.autoLogin = {
    enable = true;
    user = "rita";
  };

  hardware = {
    enableRedistributableFirmware = true;
    bluetooth.enable = true;
  };
}
