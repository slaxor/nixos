{
  config,
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "nvme"
    "rtsx_pci_sdmmc"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/mapper/TAZROOT";
    fsType = "btrfs";
  };

  boot.initrd.luks.devices."TAZROOT".device =
    "/dev/disk/by-uuid/67d81285-aa77-4d76-8e5d-509d41ae3e4b";

  fileSystems."/bin" = {
    device = "/usr/bin";
    fsType = "none";
    options = [ "bind" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/9186-8187";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  fileSystems."/home" = {
    device = "/dev/mapper/TAZHOME";
    fsType = "btrfs";
  };

  boot.initrd.luks.devices."TAZHOME".device =
    "/dev/disk/by-uuid/d9873944-a3aa-4051-801f-1f494ed51619";

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
