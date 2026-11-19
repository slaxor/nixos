# Restore drill: hare rebuilt from flake + borg inside an isolated libvirt
# network on kea that impersonates hare's /27. Order:
#   bubble-net, bubble-vm, (console: sudo passwd root), bubble-key,
#   bubble-disk, bubble-restore, bubble-install, bubble-reboot, bubble-down

bubble_ip := "144.76.195.142"
bubble := "root@" + bubble_ip
ssh_opts := "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
virsh := "virsh -c qemu:///system"
borg_repo := "ssh://u591925@u591925.your-storagebox.de:23/./borg/hare"

bubble-net:
    {{virsh}} net-define hosts/hare-bubble/network.xml
    {{virsh}} net-start bubble

bubble-vm iso:
    virt-install --connect qemu:///system --name hare-bubble \
      --memory 16384 --vcpus 4 --osinfo linux2022 \
      --disk size=300,format=qcow2,sparse=yes,bus=virtio \
      --network network=bubble,mac=52:54:00:00:01:42,model=virtio \
      --cdrom {{iso}} --boot hd,cdrom --noautoconsole

bubble-key:
    ssh-copy-id {{ssh_opts}} {{bubble}}

bubble-disk:
    scp {{ssh_opts}} hosts/hare-bubble/provision.sh {{bubble}}:/tmp/
    ssh -t {{ssh_opts}} {{bubble}} sh /tmp/provision.sh /dev/vda

bubble-restore:
    #!/bin/sh
    set -eu
    export BORG_PASSCOMMAND="sops -d --extract '[\"borg-passphrase\"]' hosts/hare/secrets.yaml"
    archive=$(borg list --last 1 --format '{archive}' {{borg_repo}})
    echo "restoring $archive"
    borg export-tar "{{borg_repo}}::$archive" - | ssh {{ssh_opts}} {{bubble}} tar -C /mnt -xp --numeric-owner
    ssh {{ssh_opts}} {{bubble}} sh -s < hosts/hare-bubble/restore-sqlite.sh

bubble-install:
    #!/bin/sh
    set -eu
    sys=$(nix build --no-link --print-out-paths .#nixosConfigurations.hare-bubble.config.system.build.toplevel)
    NIX_SSHOPTS="{{ssh_opts}}" nix copy --to "ssh://{{bubble}}?remote-store=local?root=/mnt" "$sys"
    ssh {{ssh_opts}} {{bubble}} nixos-install --no-root-passwd --no-channel-copy --system "$sys"

bubble-reboot:
    ssh {{ssh_opts}} {{bubble}} reboot

bubble-down:
    {{virsh}} destroy hare-bubble
    {{virsh}} net-destroy bubble
