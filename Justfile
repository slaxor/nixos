# Debug recipes for the NixOS flake. Import from the main justfile:
#   import 'debug.just'

host := `hostname`
cfg := ".#nixosConfigurations." + host

# Build without activating; full log goes to build.log
dbg-build:
    nh os build --no-nom -- --keep-going | tee build.log

# Only the error blocks of the last build.log
dbg-errors:
    rg -n -A12 '^error' build.log

# Full builder log of a failed derivation (path from dbg-errors)
dbg-log drv:
    nix log {{drv}}

# Build a single package with live log; failed build dir is kept in /tmp
dbg-pkg pkg:
    nix build --no-link -L --keep-failed '{{cfg}}.pkgs.{{pkg}}'

# Store path of a package's unpacked source
dbg-src pkg:
    nix build --no-link --print-out-paths '{{cfg}}.pkgs.{{pkg}}.src'

# Files that define an option, e.g. boot.initrd.systemd.enable
dbg-who opt:
    nix eval '{{cfg}}.options.{{opt}}.files' --json | jq -r '.[]'

# Evaluated value of an option, e.g. nix.package.name
dbg-val opt:
    nix eval '{{cfg}}.config.{{opt}}' --json | jq .

# ripgrep through the locked nixpkgs tree (removed options, package files)
dbg-nixpkgs pattern:
    rg -n '{{pattern}}' "$(nix eval --raw '{{cfg}}.pkgs.path')"

# Names of all system packages
dbg-pkgs:
    nix eval '{{cfg}}.config.environment.systemPackages' --apply 'map (p: p.name)' --json | jq -r '.[]' | sort

# Names of all home-manager packages
dbg-hmpkgs user="slash":
    nix eval '{{cfg}}.config.home-manager.users.{{user}}.home.packages' --apply 'map (p: p.name)' --json | jq -r '.[]' | sort

# Dependency chain from the running system to a package
dbg-why pkg:
    nix why-depends /run/current-system '{{cfg}}.pkgs.{{pkg}}'

# Failed system and user units
dbg-failed:
    systemctl --failed --no-pager
    systemctl --user --failed --no-pager

# Journal of one unit for the current boot
dbg-unit unit:
    journalctl -b -u {{unit}} --no-pager -n 50
