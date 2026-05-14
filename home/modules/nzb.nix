{ pkgs, ... }:
{
  home.packages = with pkgs; [
    sabnzbd
    nzbhydra2
    nzbget
    unrar-free
    p7zip
    par2cmdline-turbo
  ];
}
