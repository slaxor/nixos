{ pkgs, lib, ... }:
let
  # Architecture detection
  system = pkgs.system;
  isAarch64 = system == "aarch64-linux";

  # PICO-8 binary URL and hash (update these when new versions are released)
  pico8Url = "https://www.lexaloffle.com/dl/pico-8_0.2.7_${
    if isAarch64 then "arm64" else "amd64"
  }.zip";
  pico8Hash =
    if isAarch64 then
      "sha256-7fLOhUdAWFsPmIhO4J1j+auObIdy4BSKkCkntkCMnqo="
    else
      "sha256-7fLOhUdAWFsPmIhO4J1j+auObIdy4BSKkCkntkCMnqo=";

  # Fallback if fetchurl fails (for offline builds)
  pico8Fallback =
    pkgs.runCommand "pico8-fallback"
      {
        nativeBuildInputs = [ pkgs.unzip ];
      }
      ''
        mkdir -p $out/bin
        # Placeholder - user should provide the actual binary
        touch "$out/bin/pico8"
        chmod +x "$out/bin/pico8"
      '';

  pico8 = pkgs.stdenv.mkDerivation (
    {
      pname = "pico-8";
      version = "0.2.7";

      nativeBuildInputs = [
        pkgs.autoPatchelfHook
        pkgs.makeWrapper
        pkgs.unzip
      ];

      buildInputs = with pkgs; [
        SDL2
        alsa-lib
        libGL
        libx11
        libxcursor
        libxi
        libxrandr
      ];

      src = pkgs.fetchurl {
        url = pico8Url;
        sha256 = pico8Hash;
        fallback = pico8Fallback;
      };

      sourceRoot = "pico-8";

      unpackPhase = ''
        unzip $src
      '';

      installPhase = ''
        mkdir -p $out/bin
        cp pico8 pico8.dat $out/bin/
        chmod +x $out/bin/pico8
      '';

      postFixup = ''
        wrapProgram $out/bin/pico8 \
          --set SDL_VIDEODRIVER x11 \
          --set SDL_PATH ${pkgs.SDL2}/lib \
          --set LD_PRELOAD ${pkgs.SDL2}/lib/libSDL2-2.0.so.0 \
          --prefix LD_LIBRARY_PATH :${pkgs.SDL2}/lib:${pkgs.libx11}/lib:${pkgs.libxcursor}/lib:${pkgs.libxi}/lib:${pkgs.libxrandr}/lib:${pkgs.alsa-lib}/lib:${pkgs.libGL}/lib
      '';
    }
    // lib.optionalAttrs isAarch64 {
      # Architecture-specific overrides
      buildInputs = [ pkgs.SDL2 ];
    }
  );

  pico8Font = pkgs.fetchFromGitHub {
    owner = "jacobpierce";
    repo = "pico-8-font";
    rev = "e3c8f0f842e43f5b822e9ab2685d3dc130911b79";
    sha256 = "sha256-7fLOhUdAWFsPmIhO4J1j+auObIdy4BSKkCkntkCMnqo=";
  };
in
{
  home.packages = with pkgs; [
    pico8
    vscode-extensions.pollywoggames.pico8-ls
  ];

  home.file = {
    ".local/share/fonts/PICO-8.ttf".source = "${pico8Font}/fonts/PICO-8.ttf";

    ".local/share/applications/pico8.desktop".text = ''
      [Desktop Entry]
      Name=PICO-8
      Exec=${pico8}/bin/pico8
      Icon=${
        pkgs.fetchurl {
          url = "https://www.lexaloffle.com/gfx/lexaloffle-pico8.png";
          sha256 = "sha256-hbWEdCY8bpfXF77vdpdrKmUSNVKEnCCet63kjR5+A4M";
        }
      }
      Type=Application
      Categories=Game;Development;
      Terminal=false
    '';

    ".local/share/mime/packages/x-p8.xml".text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
        <mime-type type="application/x-p8">
          <comment>PICO-8 Cartridge PNG</comment>
          <glob pattern="*.p8.png"/>
        </mime-type>
      </mime-info>
    '';

    ".local/share/applications/mimeapps.list.d/pico8".text = ''
      [Default Applications]
      application/x-p8=pico8.desktop
    '';

    ".config/foot/themes/pico-8.theme".text = ''
      # -*- conf -*-
      # PICO-8
      # Based on https://www.lexaloffle.com/gfx/pico-8_palette_020.png

      [colors-dark]
      cursor = 080808 9e9e9e
      foreground = b2b2b2
      background = 080808

      regular0 = 0x000000
      regular1 = 0x1D2B53
      regular2 = 0x7E2553
      regular3 = 0x008751
      regular4 = 0xAB5236
      regular5 = 0x5F574F
      regular6 = 0xC2C3C7
      regular7 = 0xFFF1E8
      bright0 = 0xFF004D
      bright1 = 0xFFA300
      bright2 = 0xFFEC27
      bright3 = 0x00E436
      bright4 = 0x29ADFF
      bright5 = 0x83769C
      bright6 = 0xFF77A8
      bright7 = 0xFFCCAA
    '';

    ".config/foot/pico-8.ini".text = ''
      [main]
      dpi-aware=yes
      font = PICO\-8:style=Regular:size=12
      include=~/.config/foot/themes/pico-8.theme
      line-height=12
    '';
  };
}
