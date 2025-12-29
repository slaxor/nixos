{
  imports = [
    # Core
    ./base.nix
    ./network.nix
    ./polkit.nix
    ./udev.nix

    # GUI
    ./greetd.nix
    ./sway.nix
    ./fonts.nix

    # Services
    ./libvirt.nix
    ./tmate-server.nix
    ./printing.nix

    # Packages & Utils
    ./utils.nix
    ./wireshark.nix
    ./yazi.nix
    ./slaxors-custom.nix

    # Common Users
    ./users/slash.nix
  ];
}
