#!/bin/sh
# Recreates hare's disk layout with the UUIDs from hare-hardware-configuration.nix
# and mounts it on /mnt. Runs inside the NixOS installer: provision.sh /dev/vda
# Takes the LUKS passphrase from stdin, or asks twice when stdin is a terminal.
set -eu

disk=${1:?usage: provision.sh <disk>}
boot_uuid=f914ea4c-e21f-4f3b-b4b5-c86fdcf4c0d5
root_uuid=c9594a77-a71f-45ff-900d-b5218b43ef40
data_uuid=d5da6cc5-3825-4e6e-ae94-6352996bd381
dump_uuid=65b0c52e-3813-41e2-b8e9-61d7a7c815b3

partition() {
  parted -s "${disk}" -- mklabel gpt \
    mkpart bios 1MiB 2MiB set 1 bios_grub on \
    mkpart boot ext4 2MiB 1GiB \
    mkpart root 1GiB 150GiB \
    mkpart data 150GiB 250GiB \
    mkpart dump 250GiB 100%
  udevadm settle
}

ask_secret() {
  printf '%s: ' "$1"
  stty -echo
  read -r answer
  stty echo
  echo
}

read_passphrase() {
  if [ -t 0 ]; then
    ask_secret 'LUKS passphrase'
    pass=${answer}
    ask_secret 'repeat'
    [ "${pass}" = "${answer}" ] || {
      echo 'passphrases differ' >&2
      exit 1
    }
  else
    read -r pass || [ -n "${pass}" ]
  fi
  [ -n "${pass}" ] || {
    echo 'empty passphrase' >&2
    exit 1
  }
}

luks_ext4() {
  printf %s "${pass}" | cryptsetup luksFormat --batch-mode --key-file - --uuid "$2" "$1"
  printf %s "${pass}" | cryptsetup open --key-file - "$1" "$3"
  mkfs.ext4 -q "/dev/mapper/$3"
}

mount_all() {
  mount /dev/mapper/root /mnt
  mkdir -p /mnt/boot /mnt/home /mnt/dump
  mount "${disk}2" /mnt/boot
  mount /dev/mapper/data /mnt/home
  mount /dev/mapper/dump /mnt/dump
}

read_passphrase
partition
mkfs.ext4 -q -U "${boot_uuid}" "${disk}2"
luks_ext4 "${disk}3" "${root_uuid}" root
luks_ext4 "${disk}4" "${data_uuid}" data
luks_ext4 "${disk}5" "${dump_uuid}" dump
mount_all
lsblk -f "${disk}"
