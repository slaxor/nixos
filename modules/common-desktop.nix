{
  imports = [
    # Core
    ./base.nix
    ./network.nix
    ./dnsmasq.nix
    # ./ipblackhole.nix
    ./polkit.nix
    ./udev.nix
    ./local-pki.nix
    ./nix.nix

    # GUI
    ./greetd.nix
    ./sway.nix
    ./fonts.nix

    # Services
    ./docker
    ./libvirt.nix
    ./printing.nix

    # Packages & Utils
    ./utils.nix
    ./wireshark.nix
    ./yazi.nix
  ];
}
