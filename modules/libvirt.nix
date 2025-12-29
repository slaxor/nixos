{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    virter
    virtnbdbackup
    virt-manager
    OVMFFull
  ];
  virtualisation.libvirtd.qemu = {
    swtpm.enable = true;
  };
  virtualisation.spiceUSBRedirection.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_full;
    };
  };
}
