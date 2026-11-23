{ inputs, pkgs, ... }:
let
  craft = inputs.craft-nix.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ./wireguard.nix
  ];

  networking.hostName = "raven";
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";
  programs.firefox.languagePacks = [ "de" ];
  programs.thunderbird.languagePacks = [ "de" ];

  environment.systemPackages = with craft; [
    gridcraft
    photocraft
    wordcraft
  ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
  networking.firewall.interfaces.wghare.allowedTCPPorts = [ 3389 ];

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
