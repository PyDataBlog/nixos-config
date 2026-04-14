# AGENT.md

This repo is a desktop-first NixOS flake centered on the `desktop` host and a host-selected primary user.
Treat it as an explicit, portable, git-tracked configuration, not a place for clever abstractions.

## Scope

- Hosts:
  - `desktop`
- One primary user chosen per host
- Main package set: `nixos-unstable`
- Secondary package set: `nixos-25.11` as `pkgsStable`
- Flakes and `flake-parts` are required

## Repo Shape

- `hosts/` contains machine facts
- `nixosModules/` implements system behavior
- `homeManagerModules/` implements user behavior
- `users/` contains user entrypoints
- `overlays/` contains package definition changes
- `wrappers/` contains runnable/exportable artifacts
- `packages/` is for custom packaged things, not normal installs
- `flake/` wires outputs

Neovim is split intentionally:

- `homeManagerModules/nixvim/` owns plugin/runtime/package composition
- `wrappers/neovim/` owns the Lua config tree and runtime files

## Wrapper Rule

Treat everything in `wrappers/` as a standalone shared artifact by default.

- A wrapped program should be runnable by an external `x86_64-linux` user with flakes
- Do not assume the host has helper CLIs, clipboard tools, or shell extras already installed
- If a wrapped program depends on external binaries, include them in that wrapper's closure
- Keep a single shared module source of truth when the same program is exposed through Home Manager and a wrapper
- Add or keep a flake check that exercises the wrapped artifact headlessly when practical

## Non-Negotiable Rules

- `flake.nix` stays thin
- Hosts and user entrypoints compose; modules implement
- No extra host/profile/common abstractions unless there is a real second consumer
- No import-tree auto-discovery magic
- Home Manager integration stays in `nixosModules/core.nix`
- Shared system behavior lives in `nixosModules/core.nix`
- Desktop-only services live in `nixosModules/desktop-services.nix`
- Desktop-only system packages live in `nixosModules/desktop-packages.nix`
- Shared system packages live in `nixosModules/packages.nix`
- NVIDIA config stays in `nixosModules/desktop.nix`
- User packages go in `homeManagerModules/packages.nix`
- Wrappers do not replace Home Manager

## User Preferences

- Timezone: `Europe/Copenhagen`
- Locale: `en_DK.UTF-8`
- Keyboard: `us,dk` with `intl` on US and `Alt+Shift` layout switching
- Default terminal: `ghostty`
- Default shell: `nushell`
- Default editor: `nvim`
- User likes cached binaries and expects `--accept-flake-config` on flake commands when useful
- User is comfortable with bleeding-edge NixOS and NVIDIA

## Current Desktop Stack

- Display manager: greetd + ReGreet
- Compositor/session: Niri
- Shell/bar/control center: Noctalia via Quickshell
- GPU: proprietary NVIDIA on RTX 3080
- Terminal: Ghostty
- Shell UX: Nushell + Starship + zoxide
- Editor: Nixvim with Mini-inspired baseline

## Portable CLI Rule

The repo now also exposes a portable CLI environment as `.#cli`.

- It should stay runnable on external `x86_64-linux` Nix machines without this host config
- `.#cli` is the lean shell environment and uses lightweight `pkgs.neovim`
- `.#cli-full` is the full workbench and carries the wrapped `.#nixvim`
- Do not pull desktop-only baggage like CUDA/NVIDIA tools into `.#cli` unless explicitly needed
- Reuse Home Manager shell config as the source of truth instead of duplicating shell config text in the wrapper

## Niri Rule

The Niri config is intentionally fully owned in `nixosModules/niri.nix`.
Do not go back to patching upstream `default-config.kdl`.

Requirements:

- `/etc/niri/config.kdl` must be generated from this repo
- `NIRI_CONFIG=/etc/niri/config.kdl` must remain set
- the generated config must pass `niri validate` at build time
- if you change bindings or startup commands, validate the generated file again explicitly

The current config uses store paths for key spawned binaries where practical.
Keep that deterministic style.

For Niri and Noctalia integration, prefer the `noctalia-shell` wrapper over calling raw `qs`/Quickshell directly.
If behavior is unclear or a Niri-side integration needs inspiration, check Vimjoyer's Nix config first:

- `https://github.com/vimjoyer/nixconf/blob/main/wrappedPrograms/niri.nix`

Use it as a reference point for patterns, not as something to transliterate blindly.

## Nixvim Rule

The current Nixvim setup is a Mini-inspired baseline that should generally prefer MiniMax defaults unless there is a deliberate repo-specific reason to diverge.
Preserve the direction:

- keep the UX opinionated
- when changing editor defaults, check MiniMax first:
  - `/tmp/MiniMax/configs/nvim-0.13/plugin/10_options.lua`
  - `/tmp/MiniMax/configs/nvim-0.13/plugin/20_keymaps.lua`
  - `/tmp/MiniMax/configs/nvim-0.13/plugin/30_mini.lua`
- keep Nix responsible for plugin/runtime/tool composition
- keep editor behavior in the Lua tree under `wrappers/neovim/`
- prefer plain Lua entrypoints over large `extraConfigLuaPost` strings
- keep nightly Neovim scoped to the Nixvim layer, not global `pkgs.neovim`
- if behavior differs from MiniMax, assume MiniMax's default is preferred unless the repo already made an explicit local choice
- `.#nixvim` should follow the general wrapper rule above
- keep Home Manager and wrapper Neovim on one shared source of truth through `homeManagerModules/nixvim/config-tree.nix`

## Package Placement

When adding packages, default to:

- `nixosModules/packages.nix` for machine-wide tools
- `homeManagerModules/packages.nix` for personal tools

Do not put normal installs in `packages/default.nix` or `wrappers/` unless you are actually packaging or wrapping something.

## Validation Workflow

Before proposing a switch, run the checks that matter:

```bash
nix flake check --accept-flake-config
nix build --dry-run .#nixosConfigurations.desktop.config.system.build.toplevel --accept-flake-config
```

For Niri-sensitive changes, also validate the generated config path:

```bash
nix build --no-link '.#nixosConfigurations.desktop.config.environment.etc."niri/config.kdl".source' --accept-flake-config
nix shell nixpkgs#niri --command sh -lc 'niri validate -c /nix/store/...-niri-config.kdl'
```

Do not rely only on evaluation when touching runtime-sensitive desktop config.

## Documentation Sync Rule

`AGENT.md` is internal repo policy, but it still needs to match the actual tree.

When changing any of these, update the matching docs in the same commit:

- host topology or host purpose:
  - `AGENT.md`
  - `README.md`
- file ownership or architecture boundaries:
  - `AGENT.md`
  - `README.md` if user-facing behavior changed
- bootstrap, recovery, or secret handling:
  - `README.md`
  - `DISASTER_RECOVERY.md`
- wrapper behavior or exposed standalone artifacts:
  - `AGENT.md`
  - `README.md`

Practical rule:

- if a change makes an `AGENT.md` statement false, update `AGENT.md` in the same commit
- if a change makes a README command or workflow description false, update `README.md` in the same commit
- if a change alters bootstrap or recovery flow, update the matching README and recovery docs in the same commit

Use `rg` before final review to catch stale references after refactors.

## Collaboration Notes

- The user prefers direct, high-signal communication
- For major restructures, present the plan first
- Before switching desktop/session config, do a real review
- If something breaks at runtime, assume drift or nondeterminism first and verify it concretely
- Favor explicitness over framework-heavy abstraction
