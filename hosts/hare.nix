{ ... }:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  imports = [
    ./hare-hardware-configuration.nix
    ./modules/docker
  ];

  boot.kernelParams = [ "ip=dhcp" ];
  boot.initrd = {
    availableKernelModules = [ "r8169" ];
    network = {
      enable = true;
      ssh = {
        enable = true;
        port = 22;
        authorizedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOtjkbH0TGABWHHuV5Rrzt0UIKJBkPIo8tHXHoyC9kBT slash@kea"
        ];
        hostKeys = [ "/etc/ssh/ssh_host_ed25519_key" ];
        shell = "/bin/cryptsetup-askpass";
      };
    };
  };

  time.timeZone = "Europe/Berlin";
  networking.hostName = "hare";
  services.tmate-ssh-server.host = "hare.t5l.de";
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
