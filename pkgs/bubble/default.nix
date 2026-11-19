{
  writeShellApplication,
  borgbackup,
  coreutils,
  gnugrep,
  gopass,
  iproute2,
  libvirt,
  openssh,
  pv,
  sops,
  util-linux,
  virt-manager,
  flake,
}:
writeShellApplication {
  name = "bubble";
  runtimeInputs = [
    borgbackup
    coreutils
    gnugrep
    gopass
    iproute2
    libvirt
    openssh
    pv
    sops
    util-linux
    virt-manager
  ];
  runtimeEnv = {
    BUBBLE_HARE_IP = "144.76.195.142";
    BUBBLE_BORG_REPO = "ssh://u591925@u591925.your-storagebox.de:23/./borg/hare";
    BUBBLE_FLAKE_DEFAULT = "${flake}";
    BUBBLE_SSH_CONFIG = "${../../hosts/hare-bubble/ssh_config}";
    BUBBLE_NETWORK_XML = "${../../hosts/hare-bubble/network.xml}";
    BUBBLE_PROVISION = "${../../hosts/hare-bubble/provision.sh}";
    BUBBLE_RESTORE_SQLITE = "${../../hosts/hare-bubble/restore-sqlite.sh}";
    BUBBLE_SECRETS = "${../../hosts/hare/secrets.yaml}";
  };
  text = builtins.readFile ./bubble.sh;
}
