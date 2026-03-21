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
			"lp"
      "networkmanager"
      "plugdev"
      "qemu-libvirt"
      "storage"
      "video"
      "wheel"
    ];
    shell = pkgs.bash;
    uid = 10000;
    initialHashedPassword = "";
    group = "slash";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMofo4uP8iGMw2R1LFzBQu7TuiSqwS28ILf1L1Mx/xGx slash@taz"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOtjkbH0TGABWHHuV5Rrzt0UIKJBkPIo8tHXHoyC9kBT slash@kea"
    ];
  };
  # services.getty.autologinUser = "slash";
}
