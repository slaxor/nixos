{ lib, ... }:
{
  imports = [
    # Core
    ./base.nix
    ./network
    ./nix.nix

    # Services
    # ./libvirt.nix
    ./tmate-server.nix
    ./kubernetes

    # Packages & Utils
    ./utils.nix
    ./yazi.nix
  ];
  nixpkgs.config = {
    allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "barbar.nvim"
        "unrar"
      ];
  };
}
