{ lib, ... }:
{
  imports = [
    ./base.nix
    ./nix.nix
    ./fonts.nix
    ./polkit.nix
    ./printing.nix
    ./xkb.nix
    ./plasma.nix
  ];
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "barbar.nvim"
      "unrar"
    ];
}
