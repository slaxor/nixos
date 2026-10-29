{ lib, pkgs, ... }:

let
  e4thcom = pkgs.stdenv.mkDerivation {
    pname = "e4thcom";
    version = "0.9.0";

    src = pkgs.fetchurl {
      name = "e4thcom-0.9.0-stty-260522.tar.gz";
      url = "https://forth-ev.de/wiki/res/lib/exe/fetch.php/projects:e4thcom:e4thcom-0.9.0-stty-260522.tar.gz";
      hash = "sha256-YKwtfBljgpJ3JvqQ5Z8mGjkKneNX+FLqZMSi5N4XIcU=";
    };

    nativeBuildInputs = [
      pkgs.autoPatchelfHook
      pkgs.makeWrapper
    ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/e4thcom $out/bin
      cp -r . $out/share/e4thcom/
      makeWrapper $out/share/e4thcom/e4thcom $out/bin/e4thcom \
        --prefix PATH : ${lib.makeBinPath [ pkgs.coreutils ]}
      runHook postInstall
    '';

    meta.platforms = [ "x86_64-linux" ];
  };
in
{
  home.packages = [ e4thcom ];
  # e4thcom -b B115200 -d ttyUSB2 -t mecrisp-st --idm ; reset
}
