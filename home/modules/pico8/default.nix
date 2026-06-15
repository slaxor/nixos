{ pkgs, ... }:
let
  pico8 = pkgs.stdenv.mkDerivation {
    pname = "pico-8";
    version = "0.2.7";
    src = pkgs.requireFile {
      name = "pico-8_0.2.7_amd64.zip";
      sha256 = "sha256-7fLOhUdAWFsPmIhO4J1j+auObIdy4BSKkCkntkCMnqo=";
      message = ''
        Please download PICO-8 and add it to the Nix store using:
        nix-prefetch-url file:///''${HOME}/Downloads/pico-8_0.2.7_amd64.zip
      '';
      # nix-store --add-fixed sha256 pico-8_0.2.7_amd64.zip
      # nix hash file
    };
    nativeBuildInputs = [
      pkgs.autoPatchelfHook
      pkgs.makeWrapper
      pkgs.unzip
    ];
    sourceRoot = "pico-8";
    unpackPhase = ''
      unzip $src
    '';
    buildInputs = with pkgs; [
      SDL2
      alsa-lib
      libGL
      libx11
      libxcursor
      libxi
      libxrandr
    ];
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
  };

  pico8Font = builtins.fetchGit {
    url = "https://github.com/jacobpierce/pico-8-font.git";
    rev = "e3c8f0f842e43f5b822e9ab2685d3dc130911b79";
    # sourceRoot = "fonts";
  };
in
{
  home.packages = with pkgs; [
    pico8
    # pico8Font
    vscode-extensions.pollywoggames.pico8-ls
    # vimPlugins.vim-pico8-syntax
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

    # ".config/foot/themes/pico-8.theme".text = ''
    ".local/share/applications/foot/themes/pico-8.theme".text = ''
      # -*- conf -*-
      # PICO-8
      # Based on https://www.lexaloffle.com/gfx/pico-8_palette_020.png

      [colors-dark]
      cursor = 080808 9e9e9e
      foreground = b2b2b2
      background = 080808

      # selection-foreground = 080808
      # selection-background = b2ceee
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
      include=~/.local/share/applications/foot/themes/pico-8.theme
      line-height=12
    '';
  };
}
