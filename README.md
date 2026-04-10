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
- `repo.idle` for lock and monitor power-off timeouts
- `repo.nightLight` for location-aware night-light temperatures
- `repo.niri.outputs` for monitor names and modes rendered into the generated Niri config
- `repo.secrets` for repo-managed host secrets

For another machine, those values should be overridden in its host module.

## Secrets

Host secrets are managed with `sops-nix`.

- Set `repo.secrets.sopsFile` to the encrypted host secrets file
- Set `repo.secrets.userPasswordHashKey` if that file contains the primary user's password hash
- Configure the decryption identity with standard `sops.age.*` options in the host module
- Track the encrypted secret file in Git before building from a git-backed flake

The portable CLI environment ships the required tools:

```bash
portable-cli -c 'which sops; which age; which ssh-to-age; which mkpasswd'
```

Concrete bootstrap flow for a new host:

```bash
cd /path/to/repo
HASH="$(mkpasswd)"
RECIPIENT="$(ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub)"

cat > /tmp/host-secrets.yaml <<EOF
user-password-hash: "$HASH"
EOF

sops --encrypt \
  --age "$RECIPIENT" \
  --input-type yaml \
  --output-type yaml \
  /tmp/host-secrets.yaml > secrets/<host>.yaml

rm /tmp/host-secrets.yaml
git add secrets/<host>.yaml
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

Recovery is built around the encrypted secrets in Git plus a backed-up personal
age key.

See [DISASTER_RECOVERY.md](./DISASTER_RECOVERY.md) for:

- same-desktop reinstall recovery
- host-key-changed-after-reinstall recovery
- the minimal backup set to keep

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

## Local formatting and hooks

Formatting is exposed through:

```bash
nix fmt
```

Local Git hooks are managed through Nix as well. Entering the dev shell installs the hooks:

```bash
nix develop
```

Enabled hooks:

- `treefmt`
- `deadnix`

With `direnv` enabled, `.envrc` activates the same shell automatically.

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

- the configured Nushell aliases and prompt
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

Once the repo is published remotely, the standalone targets can be used as:

```bash
nix run github:PyDataBlog/nixos-config#cli
nix run github:PyDataBlog/nixos-config#nixvim
nix profile install github:PyDataBlog/nixos-config#cli
nix profile install github:PyDataBlog/nixos-config#nixvim
```

## Package Placement

Default package locations:

- machine-wide packages: `nixosModules/packages.nix`
- personal packages: `homeManagerModules/packages.nix`

Normal installs should not go in `packages/` or `wrappers/` unless the repo is actually packaging or wrapping something.
