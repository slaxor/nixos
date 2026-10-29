# Debugging a failing `nh os switch`

Every failure belongs to one of three stages. Identify the stage first; the
tools differ per stage.

| Stage      | Symptom                                               | Start with                    |
|------------|-------------------------------------------------------|-------------------------------|
| Evaluation | `error:` with a Nix stack trace, nothing gets built   | read the last `error:` line   |
| Build      | `builder for '…drv' failed`, `Cannot build …`         | `just dbg-errors`, `nix log`  |
| Activation | `Activation (test) failed`, `units failed`            | `just dbg-failed`, `dbg-unit` |

## 0. Get readable output

- `nom` breaks on unknown log events from newer Nix. Use `--no-nom` when the
  output looks like raw JSON.
- `nh` prints Nix errors on stdout: `just dbg-build` keeps them in `build.log`.
- `--keep-going` lets independent builds finish; you see all failures at once.
- Only the *first* real error matters. `Cannot build … 1 dependency failed`
  lines are consequences.

## 1. Evaluation errors

- The last `error:` paragraph is the cause; the trace above is context.
  More context: `nix eval <cfg>.config.system.build.toplevel --show-trace`.
- Removed or renamed option (`no longer has any effect`):
  - `just dbg-who boot.initrd.systemd.enable` shows the defining file.
  - `just dbg-nixpkgs '<option-name>'` shows the removal note and the
    replacement option with its type and description.
- Broken or insecure package (`Refusing to evaluate package`):
  - `just dbg-pkgs` / `just dbg-hmpkgs` and look for the name; if it is not
    listed, it is a dependency of something listed.
  - Options: remove it, wait for nixpkgs, roll back the lock, or allow it via
    `nixpkgs.config` (last resort).

## 2. Build errors

- `just dbg-errors` shows the failing derivation and the last 25 log lines.
- `just dbg-log /nix/store/…drv` gives the full log.
- `just dbg-pkg <attr>` rebuilds just that package with a live log.
- `just dbg-src <attr>` + `rg` lets you read the source the build used.
- Typical upstream breakages and local workarounds go into
  `modules/overlay-fixes.nix`; delete entries once nixpkgs is fixed.
- Many compiler-side changes (new rustc, new gcc) surface as errors in
  otherwise untouched packages. Check nixpkgs issues for the package name
  before patching.

## 3. Activation errors

- `just dbg-failed`, then `just dbg-unit <unit>`.
- A unit that did not change is not restarted. A fixed-but-unchanged unit
  stays failed until `sudo systemctl restart <unit>` or `reset-failed`.
- Stateful services (libvirt networks, databases) keep old state across
  switches. Changing the Nix definition does not change existing state.

## 4. Narrowing down after `nix flake update`

- Update one input at a time: `nix flake update nixpkgs`.
- Undo: `git checkout -- flake.lock`.
- Compare revisions: `nix flake metadata` lists locked revs of all inputs.
- Build without switching: `just dbg-build`; switch only when it is clean.

## 5. Environment surprises

- `type -a nix` / `type -a <tool>`: which binary actually runs.
- `nix profile list`: imperative installs shadow the system on `PATH`.
- `git add` new files: flakes ignore untracked files.
