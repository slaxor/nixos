# Restore drill: hare rebuilt from flake + borg on kea. The VM sits behind
# br-bubble; the "bubble" network namespace (modules/bubble-netns.nix) plays
# hare's /27 and has internet through kea. Only inside `just bubble-shell`
# does 144.76.195.142 mean the bubble; everywhere else on kea it is the real hare.
#   just bubble-shell  enter the bubble (all other recipes refuse to run outside)
#   just bubble        fresh drill, asks only for the LUKS passphrase
#   just bubble-unlock unlock an installed VM after boot
#   just bubble-down   throw the VM away and remove the namespace

bubble_ip := "144.76.195.142"
bubble := "root@" + bubble_ip
ssh_opts := "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
virsh := "virsh -c qemu:///system"
borg_repo := "ssh://u591925@u591925.your-storagebox.de:23/./borg/hare"

bubble-shell: bubble-net
    sudo -E ip netns exec bubble setpriv --reuid="$(id -u)" --regid="$(id -g)" --init-groups bash --rcfile /etc/bubble/bashrc

bubble: bubble-net bubble-vm bubble-wait bubble-disk bubble-restore bubble-install bubble-reboot
    @echo "then: just bubble-unlock"

[private]
in-bubble:
    #!/bin/sh
    set -eu
    route=$(ip -4 route get {{ bubble_ip }})
    case $route in
    *"dev lan "*) ;;
    *) echo "refusing: not inside just bubble-shell ({{ bubble_ip }} goes to the real hare: $route)" >&2; exit 1 ;;
    esac

bubble-net:
    #!/bin/sh
    set -eu
    sudo systemctl start bubble-dhcp
    has_net() { {{ virsh }} net-list "$@" --name | grep -qx bubble; }
    has_net --all || {{ virsh }} net-define hosts/hare-bubble/network.xml
    has_net || {{ virsh }} net-start bubble

bubble-iso:
    nix build --out-link .bubble-iso .#nixosConfigurations.bubble-installer.config.system.build.isoImage

bubble-vm: bubble-iso
    #!/bin/sh
    set -eu
    has_vm() { {{ virsh }} list "$@" --name | grep -qx hare-bubble; }
    if has_vm --all; then
      has_vm || {{ virsh }} start hare-bubble
      exit 0
    fi
    iso=$(echo "$(readlink -f .bubble-iso)"/iso/*.iso)
    virt-install --connect qemu:///system --name hare-bubble \
      --memory 16384 --vcpus 4 --osinfo linux2022 \
      --disk size=300,format=qcow2,sparse=yes,bus=virtio \
      --network network=bubble,mac=52:54:00:00:01:42,model=virtio \
      --cdrom "$iso" --boot hd,cdrom --noautoconsole

bubble-wait: in-bubble
    #!/bin/sh
    set -u
    for _ in $(seq 60); do
      ssh {{ ssh_opts }} -o ConnectTimeout=2 -o BatchMode=yes {{ bubble }} true && exit 0
      sleep 5
    done
    echo "no ssh on {{ bubble_ip }} after 5 minutes" >&2
    exit 1

bubble-disk: in-bubble
    scp {{ ssh_opts }} hosts/hare-bubble/provision.sh {{ bubble }}:/tmp/
    ssh -t {{ ssh_opts }} {{ bubble }} sh /tmp/provision.sh /dev/vda

bubble-restore: in-bubble
    #!/bin/sh
    set -eu
    export BORG_PASSCOMMAND="sops -d --extract '[\"borg-passphrase\"]' hosts/hare/secrets.yaml"
    archive=$(borg list --format '{archive}{NL}' {{ borg_repo }} | grep -v '\.failed$' | tail -n 1)
    [ -n "$archive" ] || { echo "no successful archive in {{ borg_repo }}" >&2; exit 1; }
    echo "restoring $archive"
    borg export-tar "{{ borg_repo }}::$archive" - \
      | nix run nixpkgs#pv \
      | ssh {{ ssh_opts }} {{ bubble }} tar -C /mnt -xp --numeric-owner
    ssh {{ ssh_opts }} {{ bubble }} sh -s < hosts/hare-bubble/restore-sqlite.sh
    ssh {{ ssh_opts }} {{ bubble }} 'mkdir -p /mnt/var/lib/rancher/k3s/agent/images && mv /mnt/var/lib/borg-k3s-images/images.tar /mnt/var/lib/rancher/k3s/agent/images/'

bubble-install: in-bubble
    #!/bin/sh
    set -eu
    sys=$(nix build --no-link --print-out-paths .#nixosConfigurations.hare-bubble.config.system.build.toplevel)
    NIX_SSHOPTS="{{ ssh_opts }}" nix copy --to "ssh://{{ bubble }}?remote-store=local?root=/mnt" "$sys"
    ssh {{ ssh_opts }} {{ bubble }} nixos-install --no-root-passwd --no-channel-copy --system "$sys"

bubble-reboot: in-bubble
    ssh {{ ssh_opts }} {{ bubble }} reboot

bubble-unlock: in-bubble
    ssh -t -p 2222 {{ bubble }} systemd-tty-ask-password-agent

bubble-down:
    #!/bin/sh
    set -u
    {{ virsh }} destroy hare-bubble
    {{ virsh }} undefine hare-bubble --remove-all-storage
    {{ virsh }} net-destroy bubble
    sudo systemctl stop bubble-netns
