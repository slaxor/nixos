{ lib, ... }:
let
  hare = import ../hare/address.nix;
in
{
  boot.loader.grub.devices = lib.mkForce [ "/dev/vda" ];

  boot.initrd.availableKernelModules = [
    "virtio_pci"
    "virtio_blk"
    "virtio_net"
  ];

  systemd.network.links."10-${hare.interface}" = {
    matchConfig.MACAddress = "52:54:00:00:01:42";
    linkConfig.Name = hare.interface;
  };
}
