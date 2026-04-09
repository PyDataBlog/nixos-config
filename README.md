# nixos-config

Desktop-first NixOS flake for one machine and a host-selected primary user declared in NixOS.

Current scope:

- one host: `desktop`
- one primary user chosen per host
- `nixos-unstable` as the main package set
- `nixos-25.11` available as `pkgsStable`
- `flake-parts`
- Home Manager
- Niri + Noctalia
- proprietary NVIDIA for an RTX 3080
- Ghostty + Nushell + Starship
- Nixvim with a MiniMax-inspired baseline

## Layout

The repo is intentionally split by responsibility:

- `hosts/` for machine facts
- `features/` for composition bundles
- `nixosModules/` for system implementation
- `homeManagerModules/` for user implementation
- `users/` for user entrypoints
- `overlays/` for package definition changes
- `wrappers/` for standalone shared artifacts
- `packages/` for future custom packages
- `flake/` for flake output wiring

## Rebuild

From the repo root:

```bash
sudo nixos-rebuild switch --flake .#desktop --accept-flake-config
```

The extra flag allows flake-provided cache settings to be used immediately.

## Host Data

Host-specific facts belong in `hosts/<name>/default.nix`, not inside shared modules.

Current host-level bindings are:

- `repo.user` for the primary NixOS/Home Manager user
- `repo.locale` for timezone and locale defaults
- `repo.location` for location-aware desktop integrations like `wlsunset`
- `repo.niri.outputs` for monitor names and modes rendered into the generated Niri config
- `repo.secrets` for repo-managed host secrets

For another machine, start by overriding those values in its host module.

## Secrets

Host secrets are managed with `sops-nix`.

- Set `repo.secrets.sopsFile` to the encrypted host secrets file
- Set `repo.secrets.userPasswordHashKey` if that file contains the primary user's password hash
- Configure the decryption identity with standard `sops.age.*` options in the host module

The portable CLI environment ships the tools you need:

```bash
portable-cli -c 'which sops; which age; which ssh-to-age; which mkpasswd'
```

## Fresh Install Bootstrap

On a brand-new machine, the user account can be bootstrapped in one of two ways:

1. Set one of these before the first switch:
   - `repo.secrets.sopsFile` together with `repo.secrets.userPasswordHashKey`
2. Or after first boot, set the password manually:

```bash
sudo passwd <user>
```

The preferred path is a SOPS-managed hashed password, not a password value in Nix.

## Disaster Recovery

Recovery is built around the encrypted secrets in Git plus your personal age key
backup.

See [DISASTER_RECOVERY.md](./DISASTER_RECOVERY.md) for:

- same-desktop reinstall recovery
- host-key-changed-after-reinstall recovery
- the minimal backup set you need to keep

## Validation

Before switching runtime-sensitive changes, especially desktop changes:

```bash
nix flake check --accept-flake-config
nix build --dry-run .#nixosConfigurations.desktop.config.system.build.toplevel --accept-flake-config
```

For Niri config changes, also validate the generated KDL explicitly:

```bash
nix build --no-link '.#nixosConfigurations.desktop.config.environment.etc."niri/config.kdl".source' --accept-flake-config
nix shell nixpkgs#niri --command sh -lc 'niri validate -c /nix/store/...-niri-config.kdl'
```

## Standalone Wrappers

Anything exposed from `wrappers/` is intended to be a standalone shared artifact.

That means:

- it should be runnable by another `x86_64-linux` user with flakes
- it should not rely on this NixOS host configuration being present
- if it needs helper binaries, those should be included in the wrapper closure

Current standalone target:

- `.#nixvim`
- `.#cli`

Run it directly from this repo:

```bash
nix run .#cli
nix run .#nixvim
```

`nix run .#cli` launches the portable CLI environment as a configured Nushell session with:

- your Nushell aliases and prompt
- wrapped `tmux` using this repo's `tmux.conf`
- wrapped `nvim` using this repo's standalone `.#nixvim`
- the core CLI toolset from this flake

Install it into a profile:

```bash
nix profile install .#cli
nix profile install .#nixvim
```

After installing `.#cli`, the package exposes:

- `portable-cli` as an explicit entrypoint
- wrapped `nu`, `tmux`, and `nvim` in the package itself

Once the repo is published remotely:

```bash
nix run github:<user>/<repo>#cli
nix run github:<user>/<repo>#nixvim
nix profile install github:<user>/<repo>#cli
nix profile install github:<user>/<repo>#nixvim
```

## Package Placement

Default package locations:

- machine-wide packages: `nixosModules/packages.nix`
- personal packages: `homeManagerModules/packages.nix`

Do not put normal installs in `packages/` or `wrappers/` unless you are actually packaging or wrapping something.
