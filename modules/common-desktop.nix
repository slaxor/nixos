{
  imports = [
    # Core
    ./base.nix
    ./network.nix
    ./polkit.nix
    ./udev.nix
    ./local-pki.nix
    ./nix.nix

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

    # Common Users
    ./users/slash.nix
  ];
}
