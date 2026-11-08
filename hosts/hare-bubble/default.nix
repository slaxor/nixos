{ lib, ... }:
{
  boot.loader.grub.devices = lib.mkForce [ "/dev/vda" ];

  boot.initrd.availableKernelModules = [
    "virtio_pci"
    "virtio_blk"
    "virtio_net"
  ];

  systemd.network.links."10-eno1" = {
    matchConfig.MACAddress = "52:54:00:00:01:42";
    linkConfig.Name = "eno1";
  };
}
