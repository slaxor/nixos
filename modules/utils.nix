{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    age
    bc
    bcachefs-tools
    bridge-utils
    coreutils
    ctags
    dconf
    docker
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
    nixfmt-rfc-style
    ntfs3g
    pciutils
    plocate
    polkit
    shellcheck
    sops
    udftools
    usbutils
  ];
}

