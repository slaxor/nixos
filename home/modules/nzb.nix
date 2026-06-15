{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nzbhydra2
    nzbget
    unrar-free
    p7zip
    par2cmdline-turbo
  ];
}
