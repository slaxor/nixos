{ pkgs, ... }:
{
  users.groups.thorsten = {
    gid = 10001;
  };

  users.users.thorsten = {
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
    uid = 10001;
    initialHashedPassword = "$6$FvifIJtfB7eMweBT$HV8OnjIXncKD4RVg5avD/bbos.umN2HODD6wKa3EfzZ2EfmRAaQ9n/Dp05MPa9CsAHY9j5REr.sRWh9axd.TF/";
    group = "thorsten";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMNFBte1GhrVSDvmCi+ICAQLEQVEuWFSFdFZyXe9m8h thorsten.eggert@gmail.com"
    ];
  };
}

