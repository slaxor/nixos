{ pkgs, ... }:
{
  users.groups.slash = {
    gid = 10000;
  };

  users.users.slash = {
    isNormalUser = true;
    extraGroups = [
      "audio"
      "dialout"
      "docker"
      "input"
      "kvm"
      "libvirtd"
      "networkmanager"
      "plugdev"
      "qemu-libvirt"
      "storage"
      "video"
      "wheel"
    ];
    shell = pkgs.bash;
    uid = 10000;
    group = "slash";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHgoR0SjvlG9RSXJYEKH6noGzXwA0vO5Jt8icqLf/wWk slash@turtle"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC1eYgW2UdnsTCk2zppw4yghgpHOhOllN3el1DuAk6Wc slash@taz"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMofo4uP8iGMw2R1LFzBQu7TuiSqwS28ILf1L1Mx/xGx slash@taz (nix)"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA0vHE8aUjdAA+HcTNmXnwePICLIju63GmMqOADRSRY4 slash@mule"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF6IgO7XKpG2RNbw2TOu25E1ZsVrqZGK3saKXrrtTfQB slash@crocodile"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOtjkbH0TGABWHHuV5Rrzt0UIKJBkPIo8tHXHoyC9kBT slash@kea"
    ];
  };
  # services.getty.autologinUser = "slash";
}
