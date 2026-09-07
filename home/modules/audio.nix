{ pkgs, ... }:
{
  home.packages = with pkgs; [
    alsa-utils
    pulseaudioFull
    timidity
  ];
}
