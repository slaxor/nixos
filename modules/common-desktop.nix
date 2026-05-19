{ lib, ... }:
{
  imports = [
    # Core
    ./base.nix
    ./nix.nix
    ./network
    ./dnsmasq
    # ./ipblackhole.nix
    ./polkit.nix
    ./udev.nix
    ./local-pki.nix

    # GUI
    ./greetd.nix
    ./sway.nix
    ./fonts.nix
    ./xkb.nix

    # Services
    # ./docker
    ./podman
    ./libvirt.nix
    ./printing.nix
    ./postgresql.nix

    # Packages & Utils
    ./utils.nix
    ./wireshark.nix
    ./yazi.nix
  ];

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "claude-code"
      "discord"
      "unrar"
    ];
}
