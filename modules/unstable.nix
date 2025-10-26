{ config, pkgs, ... }:
let
  unstable = import
    (builtins.fetchTarball https://github.com/nixos/nixpkgs/tarball/master)
    { config = config.nixpkgs.config; };
in
{
  environment.systemPackages = with pkgs; [
    nginx
    unstable.certbot
  ];
}

