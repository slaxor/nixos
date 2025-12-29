{ config, pkgs, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  imports = [
    ./taz-hardware-configuration.nix
  ];

  boot.initrd.kernelModules = [ "nouveau" ];

  time.timeZone = "Europe/Berlin";
  networking.hostName = "taz";

  services.tmate-ssh-server.host = "taz.slaxor.de";


  system.stateVersion = "25.05";
}
