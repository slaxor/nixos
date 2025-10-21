{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gcc
    gnumake
    pkg-config
    cmake
    ninja
    autoconf
    automake
    gdb
  ];

  # Optional: enable direnv for Nix shell environments
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
}

