{ pkgs, ... }:
{
  users.groups.ming = {
    gid = 10002;
  };

  users.users.ming = {
    isNormalUser = true;
    extraGroups = [
      "docker"
      "kvm"
      "libvirtd"
      "podman"
      "qemu-libvirt"
      "storage"
      "wheel"
    ];
    shell = pkgs.bash;
    uid = 10002;
    group = "ming";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICuHVmWUFgeYTUFJ9Fn9V5VpeBQqbZGq0JtENTt0fHgD mingmu@MacBook-Pro.fritz.box"
    ];
  };
}
