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
  nixpkgs.config = {
    allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "barbar.nvim"
        "diagram.nvim"
        "cspell.nvim"
        "claude-code"
        "discord"
        "nrf-udev"
        "nrf-command-line-tools"
        "nrfconnect"
        "nrfconnect-bluetooth-low-energy"
        "nrfutil"
        "nrfutil-completion"
        "pico"
        "segger-jlink"
        "segger-jlink-headless"
        "unrar"
      ];
    segger-jlink.acceptLicense = true;
    systemd.user.services.xdg-desktop-portal = {
      wants = [ "xdg-desktop-portal-gtk.service" ];
      after = [ "xdg-desktop-portal-gtk.service" ];
    };
  };
}
