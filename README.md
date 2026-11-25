# nixos

One flake for all my NixOS machines: system configuration, home-manager
for user `slash`, and secrets via sops-nix. Tracks `nixos-unstable`.

## Hosts

| Host   | Hardware              | Role    | Notes                                         |
|--------|-----------------------|---------|-----------------------------------------------|
| `kea`  | Framework 16 (AMD)    | desktop | daily driver, Sway, libvirt                   |
| `taz`  | ThinkPad P53          | desktop | kea's predecessor                             |
| `hare` | Hetzner root server   | server  | k3s, WireGuard hub, Gitea, users ming/eggert  |

## Layout

```
flake.nix            inputs, host definitions, home-manager wiring
hosts/<host>/        hardware config, host-specific settings, secrets.yaml
modules/             NixOS modules, shared via common-desktop / common-server
  overlay-fixes.nix  temporary workarounds for nixpkgs regressions
  kubernetes/        k3s stack on hare: cilium, traefik, cert-manager, gitea
  network/           WireGuard tooling (wg-peers, wg-debug)
home/                home-manager
  modules/           one module per tool or topic
  roles/             desktop.nix / server.nix: which modules a role pulls in
  hosts/             per-host home-manager overrides
users/               system users
Justfile             debug recipes (see Debugging.md)
Debugging.md         runbook for failing switches
```

A user's home configuration is composed in `flake.nix` from three layers:
the shared base (`hmBase`), a role (`home/roles/<role>.nix`) and the host
(`home/hosts/<host>.nix`).

## Inputs

| Input                 | Purpose                                       |
|-----------------------|-----------------------------------------------|
| `nixpkgs`             | `nixos-unstable`                              |
| `home-manager`        | `master`, follows nixpkgs                     |
| `nixvim`              | Neovim configuration                          |
| `nur`                 | Nix User Repository overlay                   |
| `sops-nix`            | secrets                                       |
| `nix-index-database`  | prebuilt index for `,` (comma)                |
| `slaxor-editor`       | own tool, installed system-wide               |
| `slaxor-replace`      | own tool, installed system-wide               |
| `kai`                 | fork of Kai with NixOS packaging (kea only)   |

## Usage

Switch the current host:

```sh
nh os switch
```

Build without activating, log kept in `build.log`:

```sh
just dbg-build
```

Update inputs, one at a time when something breaks:

```sh
nix flake update            # all
nix flake update nixpkgs    # one
git checkout -- flake.lock  # undo
```

New files must be `git add`ed before building; flakes ignore untracked files.

## Remote installer

`installer-wg` is a NixOS live system packed into a single EFI file. It boots from a FAT32 USB
stick, connects to hare over WireGuard and waits for `nixos-anywhere` from kea. Each file carries
its own WireGuard peer, so build one per person and delete the peer afterwards. Installer peers
live in `hub.install.subnet` (`hosts/hare/wg-hub.nix`); hare lets only `hub.install.admins` reach
them and drops everything they start themselves.

Once, on hare:

```sh
sudo wg-peers useradd install 10.13.0.240/28
```

Per person (`anna` here):

```sh
ssh hare sudo wg-peers add install anna > anna.conf
nix run .#mk-installer-efi -- anna.conf
grep Address anna.conf
shred -u anna.conf
```

`mk-installer-efi` writes `nixos-installer-anna.efi`; the address is also listed by
`sudo wg-peers list install` on hare. Send the `.efi` file together with the instructions below.
When the machine shows up, add a host to the flake like `raven` and install:

```sh
nixos-anywhere --flake .#<host> --target-host root@10.13.0.241 \
  --generate-hardware-config nixos-generate-config hosts/<host>/hardware-configuration.nix
ssh hare sudo wg-peers del install anna
```

Test a new file in a VM before sending it:

```sh
mkdir -p esp/EFI/BOOT && cp nixos-installer-anna.efi esp/EFI/BOOT/BOOTX64.EFI
qemu-system-x86_64 -enable-kvm -m 4G -nic user \
  -bios "$(nix build --print-out-paths nixpkgs#OVMF.fd)/FV/OVMF.fd" \
  -drive format=raw,file=fat:rw:esp
```

### Instructions to send along

> **Before you start:** installing Linux erases the whole disk of this computer. Back up
> everything you want to keep. You need a USB stick of at least 2 GB (it gets erased too) and
> ideally a network cable.
>
> 1. **Prepare the stick.** Format it as FAT32. On Windows: right-click the stick in Explorer,
>    *Format…*, file system *FAT32*. On a Mac: Disk Utility, *Erase*, format *MS-DOS (FAT)*,
>    scheme *Master Boot Record*.
> 2. **Copy the file.** Create a folder `EFI` on the stick and a folder `BOOT` inside it. Copy
>    the file I sent you into `EFI/BOOT` and rename it to `BOOTX64.EFI`.
> 3. **Turn off Secure Boot.** Switch the computer on and press the setup key straight away
>    (usually F2, Del or Esc; the screen often says which). Find *Secure Boot*, set it to
>    *Disabled*, save and exit.
> 4. **Start from the stick.** Plug in the stick and the network cable, switch on, press the
>    boot menu key (usually F12, F8 or Esc) and pick the USB stick.
> 5. **Wait.** After a minute a black screen with white text appears. Leave it alone and let me
>    know; I take it from there. No cable? Type `nmtui`, press Enter and choose your WiFi.

## Secrets

Secrets live in `hosts/<host>/secrets.yaml` (and `home/modules/pico8/`),
encrypted with age keys listed in `.sops.yaml`. Each host decrypts with its
SSH host key.

Add a host key:

```sh
nix run nixpkgs#ssh-to-age -- -i /etc/ssh/ssh_host_ed25519_key.pub
```

Put the result into `.sops.yaml`, add it to the matching `creation_rules`,
then re-encrypt:

```sh
sops updatekeys hosts/<host>/secrets.yaml
```

Edit a secret:

```sh
sops hosts/<host>/secrets.yaml
```

## Temporary fixes

`modules/overlay-fixes.nix` holds overrides for packages that currently fail
to build on unstable. Each entry is meant to be removed once nixpkgs has
caught up; try deleting it after every `nix flake update`.

## Debugging

See [Debugging.md](Debugging.md). Short version: decide whether the failure
is in evaluation, build or activation, then use the matching `just dbg-*`
recipe:

```sh
just --list
```
