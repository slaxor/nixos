{ config, pkgs, ... }:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  imports = [
    ./hardware-configuration.nix
    ./network.nix
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.slash = import ./home.nix;
  };

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  time.timeZone = "Europe/Berlin";

  environment.systemPackages = with pkgs; [
    linuxPackages_latest.framework-laptop-kmod
    powertop
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    blacklistedKernelModules = [
      "dvb_usb_rtl28xxu"
      "dvb_usb_v2"
      "dvb_core"
    ];
    tmp.cleanOnBoot = true;
    kernelParams = [
      "amd_pstate=active"
      "pci=noaer"
      # "mem_sleep_default=deep"
      # "usbcore.autosuspend=-1"
      # "amd_idle.max_cstate=9"

    ];
    loader = {
      systemd-boot.enable = false;
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        devices = [ "nodev" ];
      };
    };

    initrd.availableKernelModules = [
      "nvme"
      "amdgpu"
    ];
  };

  hardware = {
    enableRedistributableFirmware = true;
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        libva-utils
        rocmPackages.clr
      ];
    };
  };
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];

  hardware = {
    bluetooth.enable = true;
  };

  services = {
    blueman.enable = true;
    udisks2.enable = true;
    udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x14c3", ATTR{device}=="0x0616", RUN+="/bin/sh -c 'echo 1 > /sys/bus/pci/devices/%k/reset'"
      # Framework Laptop 16 Keyboard Module - ANSI
      KERNEL=="hidraw*", ATTRS{idVendor}=="32ac", ATTRS{idProduct}=="0012", MODE="0660", GROUP="input"
      SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="32ac", ATTR{idProduct}=="0012", ATTR{power/control}="on"
      # Framework Laptop 16 RGB Macropad
      KERNEL=="hidraw*", ATTRS{idVendor}=="32ac", ATTRS{idProduct}=="0013", MODE="0660", GROUP="input"
      SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="32ac", ATTR{idProduct}=="0013", ATTR{power/control}="on"
      # Keychron K2 HE
      KERNEL=="hidraw*", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0e20", MODE="0660", GROUP="input"
      # Logitech, Inc. Logi Bolt Receiver
      KERNEL=="hidraw*", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c548", MODE="0660", GROUP="input"
      # ---------------------------------------------------------------------------
      # Suspend fix — the actual root cause of the GPU crashes
      # ---------------------------------------------------------------------------
      # The HDMI audio companion of the dGPU (03:00.1, driven by snd_hda_intel
      # despite being AMD hardware) goes into D3cold independently via runtime PM.
      # When system suspend then tries to touch it, the GPU state gets corrupted,
      # leading to the sdma0 timeout → device lost from bus cascade you saw.
      # This rule forces the audio device to stay in D0 (active), preventing the
      # race. The GPU itself (03:00.0) is unaffected and can still runtime-suspend
      # normally via amdgpu runpm.
      SUBSYSTEM=="pci", ATTR{vendor}=="0x1002", ATTR{class}=="0x040300", ATTR{power/control}="on"
    '';

    tlp = {
      enable = false;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        PLATFORM_PROFILE_ON_AC = "balanced";
        PLATFORM_PROFILE_ON_BAT = "low-power";
        PCIE_ASPM_ON_AC = "default";
        PCIE_ASPM_ON_BAT = "powersupersave";
        RUNTIME_PM_ON_AC = "on";
        RUNTIME_PM_ON_BAT = "auto";
        DISK_DEVICES = "nvme0n1";
        DISK_IOSCHEDULER_ON_BAT = "none";
        WIFI_PWR_ON_AC = "off";
        WIFI_PWR_ON_BAT = "on";
        USB_AUTOSUSPEND = 1;
        USB_DENYLIST = "32ac:0012 32ac:0013";
        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0;
      };
    };
    power-profiles-daemon.enable = false;
    auto-cpufreq.enable = true;
  };

  powerManagement.resumeCommands = ''
    modprobe -r mt7921e mt7921_common mt792x_lib mt76_connac_lib mt76
    modprobe mt7921e
  '';

  systemd = {
    services = {
      systemd-journald.serviceConfig.WatchdogSec = "10min";
    };
  };
}
