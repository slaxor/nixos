{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  craft = inputs.craft-nix.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ./wireguard.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  networking.hostName = "raven";
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";
  programs.firefox.languagePacks = [ "de" ];
  programs.thunderbird.languagePacks = [ "de" ];

  environment.etc = {
    "xdg/kscreenlockerrc".text = lib.generators.toINI { } {
      Daemon.Timeout = 10;
    };
    "xdg/baloofilerc".text = lib.generators.toINI { } {
      "Basic Settings".Indexing-Enabled = false;
    };
  };

  zramSwap.enable = true;

  environment.systemPackages = with craft; [
    gridcraft
    photocraft
    wordcraft
  ];

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
