{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    netop
    atop
    btop
    ctop
    age
    bc
    bcachefs-tools
    bluetuith
    bridge-utils
    coreutils
    ctags
    dconf
    exfat
    f2fs-tools
    fd
    fdupes
    file
    fzf
    gitui
    gnupg
    hyprpolkitagent
    libguestfs
    lshw
    mtr
    ncdu
    netcat
    ntfs3g
    pciutils
    plocate
    polkit
    shellcheck
    sops
    udftools
    usbutils
    minio-client
    syncthing
  ];

  services = {
    upower.enable = true;
  };

  networking.firewall = {
    allowedTCPPorts = [
      22000 # Syncthing
    ];
  };
}
