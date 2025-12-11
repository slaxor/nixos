{ inputs, pkgs, ... }:
let
  # slaxor-replace-pkg = pkgs.stdenv.mkDerivation {
  # pname = "sv";
  # version = "0.0.1-git";
  # src = inputs.slaxor-replace-src;
  # nativeBuildInputs = [ pkgs.go ];
  # buildPhase = ''
  # runHook preBuild
  # go mod download github.com/spf13/pflag
  # go build -o sv ./cmd/sv
  # runHook postBuild
  # '';

  # installPhase = ''
  # runHook preInstall
  # mkdir -p $out/bin
  # cp sv $out/bin/sv
  # runHook postInstall
  # '';
  # hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  # };

  slaxor-replace-pkg = pkgs.buildGoModule {
    pname = "sv";
    version = "0.0.1-git"; # You can change this version
    src = inputs.slaxor-replace-src;
    proxyVendor = true;
    vendorHash = null;
  };
in
{
  environment.systemPackages = [
    # slaxor-replace-pkg
    # inputs.slaxor-editor.packages.${pkgs.system}.default
  ];
}
