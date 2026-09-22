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
    ./fonts.nix
    ./greetd.nix
    ./sway.nix
    ./xkb.nix

    # Services
    ./audio.nix
    # ./docker
    ./libvirt.nix
    ./podman
    ./postgresql.nix
    ./printing.nix

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
        "nrf-udev"
        "nrf-command-line-tools"
        "nrfconnect"
        "nrfconnect-bluetooth-low-energy"
        "nrfutil"
        "nrfutil-completion"
        "pico"
        "segger-jlink"
        "segger-jlink-headless"
        "steam"
        "steam-unwrapped"
        "steam-original"
        "steam-run"
        "tampermonkey"
        "unrar"
      ];
    segger-jlink.acceptLicense = true;
    systemd.user.services.xdg-desktop-portal = {
      wants = [ "xdg-desktop-portal-gtk.service" ];
      after = [ "xdg-desktop-portal-gtk.service" ];
    };
  };
}
