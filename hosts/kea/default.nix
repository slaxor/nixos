{
  pkgs,
  lib,
  ...
}:
let
  # curl -sS 'https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/plain/drivers/gpu/drm/amd/include/amd_shared.h?h=v7.2.10' | rg -A40 'enum DC_DEBUG_MASK'
  #
  # Bit	Name	Effect
  # 0x1	DC_DISABLE_PIPE_SPLIT	no splitting of one output across several display pipes
  # 0x2	DC_DISABLE_STUTTER	no memory self-refresh (“stutter”) during scanout
  # 0x4	DC_DISABLE_DSC	no Display Stream Compression
  # 0x8	DC_DISABLE_CLOCK_GATING	display clocks stay on
  # 0x10	DC_DISABLE_PSR	no Panel Self Refresh
  # 0x20	DC_FORCE_SUBVP_MCLK_SWITCH	forces memory clock switching via SubVP (dGPU)
  # 0x40	DC_DISABLE_MPO	no multi-plane overlay; everything composited into one plane
  # 0x80	DC_ENABLE_DPIA_TRACE	debug tracing for USB4/DP tunneling
  # 0x100	DC_ENABLE_DML2	newer display-mode library for bandwidth calculations
  # 0x200	DC_DISABLE_PSR_SU	keeps PSR but disables selective-update (PSR2)
  # 0x400	DC_DISABLE_REPLAY	no Panel Replay
  # 0x800	DC_DISABLE_IPS	no Idle Power States of the display engine
  # 0x1000	DC_DISABLE_IPS_DYNAMIC	IPS only on static screens
  # 0x2000	DC_DISABLE_IPS2_DYNAMIC	the deepest IPS level only on static screens
  # 0x4000	DC_FORCE_IPS_ENABLE	forces IPS on
  # 0x8000	DC_DISABLE_ACPI_EDID	ignores the EDID supplied by ACPI firmware
  #
  # The counterpart is amdgpu.dcfeaturemask, which enables features that
  # are off by default.
  # For a finer-grained test on your panel, 0x200 is worth a try. It
  # keeps basic PSR and only disables selective update, the more complex
  # PSR2 mode. If that alone, or together with 0x400, keeps resume
  # stable, you keep most of the power savings.
  dcDebugBits = {
    DC_DISABLE_PIPE_SPLIT = 1;
    DC_DISABLE_STUTTER = 2;
    DC_DISABLE_DSC = 4;
    DC_DISABLE_CLOCK_GATING = 8;
    DC_DISABLE_PSR = 16;
    DC_FORCE_SUBVP_MCLK_SWITCH = 32;
    DC_DISABLE_MPO = 64;
    DC_ENABLE_DPIA_TRACE = 128;
    DC_ENABLE_DML2 = 256;
    DC_DISABLE_PSR_SU = 512;
    DC_DISABLE_REPLAY = 1024;
    DC_DISABLE_IPS = 2048;
    DC_DISABLE_IPS_DYNAMIC = 4096;
    DC_DISABLE_IPS2_DYNAMIC = 8192;
    DC_FORCE_IPS_ENABLE = 16384;
    DC_DISABLE_ACPI_EDID = 32768;
  };
  dcdebugmask =
    names:
    "amdgpu.dcdebugmask=0x"
    + lib.toHexString (lib.foldl' builtins.bitOr 0 (map (name: dcDebugBits.${name}) names));
in
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
      (dcdebugmask [
        # "DC_DISABLE_PSR"
        "DC_DISABLE_REPLAY"
      ])

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

    initrd = {
      availableKernelModules = [
        "nvme"
        "amdgpu"
      ];
      # luks.devices = {
      # KEAROOT.crypttabExtraOpts = [ "fido2-device=auto" ];
      # KEADATA.crypttabExtraOpts = [ "fido2-device=auto" ];
      # KEAHOME.crypttabExtraOpts = [ "fido2-device=auto" ];
      # };
    };

    extraModprobeConfig = "options iwlmvm power_scheme=1";
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

    power-profiles-daemon.enable = true;
  };
  systemd = {
    services = {
      systemd-journald.serviceConfig.WatchdogSec = "10min";
    };
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # optional
    gamescopeSession.enable = true; # optional, for handheld/gamescope launches
  };
}
