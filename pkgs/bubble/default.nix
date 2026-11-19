{
  symlinkJoin,
  writeShellApplication,
  writeText,
  writeTextDir,
  borgbackup,
  coreutils,
  gnugrep,
  gopass,
  iproute2,
  libvirt,
  openssh,
  pv,
  rsync,
  sops,
  util-linux,
  virt-manager,
  flake,
}:
let
  hare = import ../../hosts/hare/address.nix;
  storageBox = "u591925@u591925.your-storagebox.de";
  sshConfig = writeText "bubble-ssh-config" ''
    Host installer
      HostName ${hare.ipv4.address}
      User root
      StrictHostKeyChecking no
      UserKnownHostsFile /dev/null
  '';
  bubble = writeShellApplication {
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
      rsync
      sops
      util-linux
      virt-manager
    ];
    runtimeEnv = {
      BUBBLE_HARE_IP = hare.ipv4.address;
      BUBBLE_BORG_REPO = "ssh://${storageBox}:23/./borg/hare";
      BUBBLE_BORG_MIRROR_SOURCE = "${storageBox}:borg/hare/";
      BUBBLE_BORG_SSH_PORT = "23";
      BUBBLE_FLAKE_DEFAULT = "${flake}";
      BUBBLE_SSH_CONFIG = "${sshConfig}";
      BUBBLE_NETWORK_XML = "${../../hosts/hare-bubble/network.xml}";
      BUBBLE_PROVISION = "${../../hosts/hare-bubble/provision.sh}";
      BUBBLE_RESTORE_SQLITE = "${../../hosts/hare-bubble/restore-sqlite.sh}";
      BUBBLE_SECRETS = "${../../hosts/hare/secrets.yaml}";
    };
    text = builtins.readFile ./bubble.sh;
  };
in
symlinkJoin {
  name = "bubble";
  paths = [
    bubble
    (writeTextDir "share/bash-completion/completions/bubble" (builtins.readFile ./completion.bash))
  ];
}
