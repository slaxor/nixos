{
  imports = [
    # Core
    ./base.nix
    ./network.nix

    # Services
    ./libvirt.nix
    ./tmate-server.nix

    # Packages & Utils
    ./utils.nix
    ./yazi.nix
    ./slaxors-custom.nix

    # Common Users
    ./users/slash.nix
  ];
}
