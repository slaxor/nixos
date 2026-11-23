{ pkgs, ... }:
{
  services.desktopManager.plasma6.enable = true;
  services.displayManager.plasma-login-manager.enable = true;
  networking.networkmanager.enable = true;

  programs = {
    firefox.enable = true;
    thunderbird.enable = true;
    kdeconnect.enable = true;
  };

  hardware.sane.enable = true;

  environment.systemPackages = with pkgs; [
    hunspell
    hunspellDicts.de_DE
    hunspellDicts.en_US
    kdePackages.kcalc
    kdePackages.skanpage
    libreoffice-qt
    vlc
  ];
}
