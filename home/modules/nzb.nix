{ pkgs, ... }:
{
  home.packages = with pkgs; [
    sabnzbd
    nzbhydra2
    nzbget
  ];

  home.file = {
    # ".local/share/fonts/PICO-8.ttf".source = "${pico8Font}/fonts/PICO-8.ttf";

    # ".local/share/applications/pico8.desktop".text = ''
    # [Desktop Entry]
    # Name=PICO-8
    # Exec=${pico8}/bin/pico8
    # Icon=${
    # pkgs.fetchurl {
    # url = "https://www.lexaloffle.com/gfx/lexaloffle-pico8.png";
    # sha256 = "sha256-hbWEdCY8bpfXF77vdpdrKmUSNVKEnCCet63kjR5+A4M";
    # }
    # }
    # Type=Application
    # Categories=Game;Development;
    # Terminal=false
    # '';
  };
}
