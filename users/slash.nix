{ pkgs, ... }:
{
  users = {
    groups.slash = {
      gid = 10000;
    };

    users.slash = {
      isNormalUser = true;
      extraGroups = [
        "audio"
        "dialout"
        "docker"
        "hoarders"
        "input"
        "kvm"
        "libvirtd"
        "lp"
        "networkmanager"
        "podman"
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
      openssh.authorizedKeys.keys = import ./slash-keys.nix;
    };
  };

  security.sudo.extraRules = [
    {
      users = [ "slash" ];
      commands = [
        {
          command = "/udevadm trigger";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/nix/store/*/bin/switch-to-configuration";
        }
        {
          command = "/run/current-system/sw/bin/nix-env";
        }
      ];
    }
  ];
  # services.getty.autologinUser = "slash";
}
