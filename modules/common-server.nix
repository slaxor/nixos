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
    # ./slaxors-custom.nix
  ];
}
