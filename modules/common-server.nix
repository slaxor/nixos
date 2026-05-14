{
  imports = [
    # Core
    ./base.nix
    ./network

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
