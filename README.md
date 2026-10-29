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
