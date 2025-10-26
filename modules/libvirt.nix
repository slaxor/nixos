
{ config, pkgs, ... }:

{
  virtualisation.libvirtd.enable = true;
  # Enable TPM emulation (optional)
  virtualisation.libvirtd.qemu = {
    swtpm.enable = true;
    ovmf.packages = [ pkgs.OVMFFull.fd ];
  };
  # Enable USB redirection (optional)
  virtualisation.spiceUSBRedirection.enable = true;

#   # Enable the libvirt service
#   services.libvirtd = {
#     enable = true;
#     virtDrivers = [ "kvm" ];
#     extraConfig = ''
#       user = "libvirt-qemu"
#       group = "libvirt"
#     '';
#   };
#
#   # Enable QEMU for multiple architectures
#   virtualisation.qemu = {
#     enable = true;
#     package = pkgs.qemu_full;  # You can specify "qemu_full" to get a broader set of QEMU features
#     # Enable support for different architectures like ARM, ARM64, RISCV
#     extraPackages = with pkgs; [
#       qemu_x86_64
#       qemu_aarch64
#       qemu_arm
#       qemu_riscv
#     ];
#   };
#
#   # Enable UEFI for VMs
#   virtualisation.qemu.efiSupport = true;  # Enable UEFI support for VM booting
#   virtualisation.qemu.efiFiles = pkgs.qemu_ovmf;
#
#   # Add additional packages, e.g., libvirt tools for management via CLI
#   environment.systemPackages = with pkgs; [
#     libvirt
#     libvirtTools
#     virt-manager
#     qemu
#   ];
}
