# shellcheck shell=bash
set -euo pipefail

readonly vm=hare-bubble
readonly vm_mac=52:54:00:00:01:42
readonly hare_ip=${BUBBLE_HARE_IP:?}
readonly flake=${BUBBLE_FLAKE:-${BUBBLE_FLAKE_DEFAULT:?}}
readonly ssh_config=${BUBBLE_SSH_CONFIG:?}
readonly network_xml=${BUBBLE_NETWORK_XML:?}
readonly provision=${BUBBLE_PROVISION:?}
readonly restore_sqlite=${BUBBLE_RESTORE_SQLITE:?}
readonly secrets=${BUBBLE_SECRETS:?}
readonly iso_link=${XDG_CACHE_HOME:-${HOME}/.cache}/bubble/installer-iso
export BORG_REPO=${BUBBLE_BORG_REPO:?}
export LIBVIRT_DEFAULT_URI=qemu:///system

usage() {
  cat <<EOF
bubble: restore drill for hare inside an isolated network namespace on kea

  bubble install         whole drill on a fresh VM: vm, wait, disk, restore, system, reboot
  bubble unlock          LUKS passphrase over initrd ssh (after reboot or virsh start)
  bubble enter           shell in which ${hare_ip} is the bubble VM
  bubble ssh [user]      ssh to the restored hare (default user: slash)
  bubble delete          remove VM, disk, libvirt network and namespace

  steps of install, to resume after a failure:
  bubble vm              create the VM booting the installer, or start it
  bubble wait            wait until the installer answers on ssh   (needs vm)
  bubble disk            partitions + LUKS on /mnt, gopass luks/hare (needs wait)
  bubble restore         newest successful borg archive into /mnt  (needs disk)
  bubble system          build hare-bubble, nixos-install into /mnt (needs restore)
  bubble reboot          reboot the installer into the restored hare (needs system)

Every command except delete switches into the namespace by itself (sudo).
BUBBLE_FLAKE=path overrides the flake to build from (default: the one kea was built from).
Once per machine: kea's ssh key on the storage box, sops access to hare's secrets, luks/hare in gopass.
EOF
}

location() {
  local route
  route=$(ip -4 route get "${hare_ip}")
  case ${route} in
  *"dev lan "*) echo inside ;;
  *) echo outside ;;
  esac
}

on_installer() {
  ssh -F "${ssh_config}" installer "$@"
}

require_on_installer() {
  local message=${1}
  shift
  if ! ssh -F "${ssh_config}" installer "$@"; then
    echo "${message}" >&2
    exit 1
  fi
}

start_network() {
  local defined definition active
  sudo systemctl start bubble-dhcp
  defined=$(virsh net-list --all --name)
  if grep -qx bubble <<<"${defined}"; then
    definition=$(virsh net-dumpxml bubble)
    if ! grep -q "name='br-bubble'" <<<"${definition}"; then
      virsh net-destroy bubble || true
      virsh net-undefine bubble
      virsh net-define "${network_xml}"
    fi
  else
    virsh net-define "${network_xml}"
  fi
  active=$(virsh net-list --name)
  grep -qx bubble <<<"${active}" || virsh net-start bubble
}

reexec_inside() {
  local uid gid ip_bin setpriv_bin
  start_network
  uid=$(id -u)
  gid=$(id -g)
  ip_bin=$(command -v ip)
  setpriv_bin=$(command -v setpriv)
  exec sudo -E "${ip_bin}" netns exec bubble \
    "${setpriv_bin}" --reuid="${uid}" --regid="${gid}" --init-groups "${0}" "$@"
}

cmd_enter() {
  bash --rcfile /etc/bubble/bashrc
}

cmd_vm() {
  local defined running iso_dir isos
  defined=$(virsh list --all --name)
  if grep -qx "${vm}" <<<"${defined}"; then
    running=$(virsh list --name)
    grep -qx "${vm}" <<<"${running}" || virsh start "${vm}"
    return
  fi
  mkdir -p "${iso_link%/*}"
  nix build --out-link "${iso_link}" "${flake}#nixosConfigurations.bubble-installer.config.system.build.isoImage"
  iso_dir=$(readlink -f "${iso_link}")
  isos=("${iso_dir}"/iso/*.iso)
  virt-install --name "${vm}" \
    --memory 16384 --vcpus 4 --osinfo linux2022 \
    --disk size=300,format=qcow2,sparse=yes,bus=virtio \
    --network "network=bubble,mac=${vm_mac},model=virtio" \
    --cdrom "${isos[0]}" --boot hd,cdrom --noautoconsole
}

cmd_wait() {
  local tries
  for ((tries = 0; tries < 60; tries++)); do
    if ssh -F "${ssh_config}" -o ConnectTimeout=2 -o BatchMode=yes installer true; then
      return
    fi
    sleep 5
  done
  echo "no ssh to the installer after 5 minutes: is the VM running it? (bubble vm)" >&2
  exit 1
}

cmd_disk() {
  scp -F "${ssh_config}" "${provision}" installer:/tmp/provision.sh
  gopass show -o luks/hare | on_installer sh /tmp/provision.sh /dev/vda
}

cmd_restore() {
  local archives archive
  require_on_installer "/mnt is not mounted in the VM: run 'bubble disk' first" mountpoint -q /mnt
  export BORG_PASSCOMMAND="sops -d --extract '[\"borg-passphrase\"]' ${secrets}"
  archives=$(borg list --format '{archive}{NL}')
  archive=$(grep -v '\.failed$' <<<"${archives}" | tail -n 1)
  if [[ -z ${archive} ]]; then
    echo "no successful archive in ${BORG_REPO}" >&2
    exit 1
  fi
  echo "restoring ${archive}"
  borg export-tar "::${archive}" - | pv | on_installer tar -C /mnt -xp --numeric-owner
  on_installer sh -s <"${restore_sqlite}"
  restore_images "${archive}"
}

restore_images() {
  local exported=/mnt/var/lib/borg-k3s-images
  if ! ssh -F "${ssh_config}" installer "set -- ${exported}/*.tar; test -e \"\$1\""; then
    echo "warning: ${1} contains no container images, pods in the bubble will stay in ImagePullBackOff" >&2
    return
  fi
  on_installer "mkdir -p /mnt/var/lib/rancher/k3s/agent/images && mv ${exported}/*.tar /mnt/var/lib/rancher/k3s/agent/images/"
}

cmd_system() {
  local system
  require_on_installer "no restored host key in /mnt: run 'bubble restore' first" \
    test -f /mnt/etc/ssh/ssh_host_ed25519_key
  system=$(nix build --no-link --print-out-paths "${flake}#nixosConfigurations.hare-bubble.config.system.build.toplevel")
  NIX_SSHOPTS="-F ${ssh_config}" nix copy --to "ssh://installer?remote-store=local?root=/mnt" "${system}"
  on_installer nixos-install --no-root-passwd --no-channel-copy --system "${system}"
}

cmd_reboot() {
  on_installer systemctl reboot --no-block
}

cmd_install() {
  local defined
  defined=$(virsh list --all --name)
  if grep -qx "${vm}" <<<"${defined}"; then
    echo "${vm} exists already: 'bubble delete' for a fresh drill, or run the remaining steps" >&2
    exit 1
  fi
  cmd_vm
  cmd_wait
  cmd_disk
  cmd_restore
  cmd_system
  cmd_reboot
  echo "next: bubble unlock"
}

cmd_unlock() {
  ssh -t -p 2222 "root@${hare_ip}" systemd-tty-ask-password-agent
}

cmd_ssh() {
  ssh "${1:-slash}@${hare_ip}"
}

cmd_delete() {
  virsh destroy "${vm}" || true
  virsh undefine "${vm}" --remove-all-storage || true
  virsh net-destroy bubble || true
  sudo systemctl stop bubble-netns
}

list_commands() {
  local functions function_name
  functions=$(declare -F)
  while read -r _ _ function_name; do
    if [[ ${function_name} == cmd_* ]]; then
      printf '%s\n' "${function_name#cmd_}"
    fi
  done <<<"${functions}"
  echo help
}

main() {
  local command=${1:-help} where
  shift || true
  if [[ ${command} == help || ${command} == -h || ${command} == --help ]]; then
    usage
    return
  fi
  if [[ ${command} == __commands ]]; then
    list_commands
    return
  fi
  if ! declare -F "cmd_${command}" >/dev/null; then
    usage >&2
    exit 1
  fi
  where=$(location)
  if [[ ${command} == delete ]]; then
    if [[ ${where} == inside ]]; then
      echo "leave the bubble first (exit), then 'bubble delete'" >&2
      exit 1
    fi
  elif [[ ${where} == outside ]]; then
    reexec_inside "${command}" "$@"
  fi
  "cmd_${command}" "$@"
}

main "$@"
