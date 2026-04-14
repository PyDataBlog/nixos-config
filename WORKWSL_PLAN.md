# workwsl plan

<!--toc:start-->

- [workwsl plan](#workwsl-plan)
  - [Goal](#goal)
  - [Constraint](#constraint)
  - [Recommended Bootstrap Model](#recommended-bootstrap-model)
  - [Terminal-First Principles](#terminal-first-principles)
  - [Certificate Policy](#certificate-policy)
  - [Current Repo Shape](#current-repo-shape)
  - [File-by-File Refactor Plan](#file-by-file-refactor-plan)
    - [1. [flake.nix](./flake.nix)](#1-flakenixflakenix)
    - [2. [flake/hosts.nix](./flake/hosts.nix)](#2-flakehostsnixflakehostsnix)
    - [3. [nixosModules/base.nix](./nixosModules/base.nix)](#3-nixosmodulesbasenixnixosmodulesbasenix)
    - [4. [features/nixos/base.nix](./features/nixos/base.nix)](#4-featuresnixosbasenixfeaturesnixosbasenix)
    - [5. [nixosModules/packages.nix](./nixosModules/packages.nix)](#5-nixosmodulespackagesnixnixosmodulespackagesnix)
    - [6. [users/home.nix](./users/home.nix)](#6-usershomenixusershomenix)
    - [7. [users/common.nix](./users/common.nix)](#7-userscommonnixuserscommonnix)
    - [8. [users/workwsl.nix](./users/workwsl.nix)](#8-usersworkwslnixusersworkwslnix)
    - [9. `users/wslbootstrap.nix`](#9-userswslbootstrapnix)
    - [10. [features/nixos/wsl.nix](./features/nixos/wsl.nix)](#10-featuresnixoswslnixfeaturesnixoswslnix)
    - [11. [hosts/wslbootstrap/default.nix](./hosts/wslbootstrap/default.nix)](#11-hostswslbootstrapdefaultnixhostswslbootstrapdefaultnix)
    - [12. [hosts/workwsl/default.nix](./hosts/workwsl/default.nix)](#12-hostsworkwsldefaultnixhostsworkwsldefaultnix)
    - [13. Local `zscaler.pem` plus GitHub secret `ZSCALER_PEM`](#13-local-zscalerpem-plus-github-secret-zscalerpem)
    - [14. [.github/workflows/release-wsl-bootstrap.yml](./.github/workflows/release-wsl-bootstrap.yml)](#14-githubworkflowsrelease-wsl-bootstrapymlgithubworkflowsrelease-wsl-bootstrapyml)
    - [15. [README.md](./README.md)](#15-readmemdreadmemd)
  - [Bootstrap Sequence](#bootstrap-sequence)
    - [Phase A: Desktop-side refactor](#phase-a-desktop-side-refactor)
    - [Phase B: Publish the bootstrap image](#phase-b-publish-the-bootstrap-image)
    - [Phase C: Install the bootstrap image on the work laptop](#phase-c-install-the-bootstrap-image-on-the-work-laptop)
    - [Phase D: Validate trust before cloning](#phase-d-validate-trust-before-cloning)
    - [Phase E: Clone the repo inside WSL](#phase-e-clone-the-repo-inside-wsl)
    - [Phase F: First on-device rebuild to the real host](#phase-f-first-on-device-rebuild-to-the-real-host)
  - [Work PC Checklist](#work-pc-checklist)
    - [1. Download and install the bootstrap image](#1-download-and-install-the-bootstrap-image)
    - [2. Boot into the bootstrap distro](#2-boot-into-the-bootstrap-distro)
    - [3. Verify TLS trust before cloning anything](#3-verify-tls-trust-before-cloning-anything)
    - [4. Restore the personal age key](#4-restore-the-personal-age-key)
    - [5. Clone the repo into the Linux filesystem](#5-clone-the-repo-into-the-linux-filesystem)
    - [6. Switch to the real `workwsl` host](#6-switch-to-the-real-workwsl-host)
    - [7. Restart the distro once](#7-restart-the-distro-once)
    - [8. Verify the final state](#8-verify-the-final-state)
    - [9. Optional full validation pass](#9-optional-full-validation-pass)
  - [First-Pass Host Defaults](#first-pass-host-defaults)
  - [Secrets Strategy for WSL](#secrets-strategy-for-wsl)
  - [Suggested Implementation Order](#suggested-implementation-order)
  - [Completion Criteria](#completion-criteria)
  <!--toc:end-->

Status: phases 1 to 4 are implemented in the repo. This file is the continuation point for publishing `wslbootstrap`, installing it on the work laptop, and converging onto `workwsl`.

## Goal

Add a new `workwsl` host that:

- runs under NixOS-WSL on the work laptop
- is terminal-first by default
- trusts the corporate `zscaler.pem` CA before the first useful network fetch
- reuses the repo's common shell/editor/developer setup
- does not inherit desktop-only services like Niri, Noctalia, printing, audio, or NVIDIA
- does not assume Linux GUI applications are part of the first bootstrap

## Constraint

The work network requires `zscaler.pem` before:

- `git clone`
- `nix flake metadata`
- `nixos-rebuild`
- substituter access such as `https://cache.nixos.org`

That makes the bootstrap order important. A stock NixOS-WSL install first and repo integration second is the wrong order.

## Recommended Bootstrap Model

Use two WSL targets, not one:

- `wslbootstrap`: minimal published image with only NixOS-WSL plus the corporate CA
- `workwsl`: the real terminal-first host inside this repo

Build and publish `wslbootstrap` first, then use it to get a working base WSL install on the laptop. After that, clone the repo and switch to `workwsl`.

That keeps the certificate problem out of the critical path:

1. add a minimal `wslbootstrap` host with only certificate trust
2. publish its tarball from GitHub Actions as a release artifact
3. install that image on the work laptop
4. validate that TLS trust works
5. clone the repo inside WSL
6. build and switch to the real `workwsl` host later

## Terminal-First Principles

`workwsl` should be treated as a terminal workstation, not a reduced desktop host.

That means:

- prioritize `nu`, `tmux`, `nvim`, CLI wrappers, and developer tooling
- prefer Windows-hosted GUI tools when a GUI is needed
- do not add Linux desktop services by default
- do not add Linux GUI applications by default just because they exist on `desktop`
- only add WSL-specific integration when it improves terminal workflows directly

`wslbootstrap` is even narrower than that:

- just the repo/bootstrap tooling that is always needed (`git`)
- no developer stack
- no Home Manager feature layering beyond what is absolutely required
- just enough system state to boot, trust the corporate CA, and reach the network successfully

## Certificate Policy

`zscaler.pem` is a trust anchor, not a secret. It should not go through SOPS.

Chosen path:

- GitHub Actions secret: `ZSCALER_PEM`
- local validation input: `ZSCALER_PEM_FILE=/path/to/zscaler.pem`

Current implementation:

- the repo does not track the PEM
- [nixosModules/corporate-ca.nix](./nixosModules/corporate-ca.nix) accepts either inline `ZSCALER_PEM` or `ZSCALER_PEM_FILE` during impure evaluation and turns it into a real store path
- that module also folds the PEM into nixpkgs `cacert`, so `fetchgit` builders use the same trust bundle as the host
- the active CA is persisted on installed hosts at `/var/lib/nixos-config/corporate-ca.pem`, so later on-device WSL rebuilds can reuse it without passing the PEM again
- the release workflow materializes `ZSCALER_PEM` into a temporary file and exports `ZSCALER_PEM_FILE`

## Current Repo Shape

The repo is now split enough to support WSL cleanly:

- [flake/hosts.nix](./flake/hosts.nix) now defines `desktop`, `wslbootstrap`, and `workwsl`
- [users/common.nix](./users/common.nix) holds the shared Home Manager user entrypoint
- [users/home.nix](./users/home.nix) is now the desktop user entrypoint
- [users/workwsl.nix](./users/workwsl.nix) is now the terminal-first WSL user entrypoint
- [nixosModules/core.nix](./nixosModules/core.nix) holds shared system state
- [nixosModules/desktop-services.nix](./nixosModules/desktop-services.nix) and [nixosModules/desktop-packages.nix](./nixosModules/desktop-packages.nix) isolate desktop-only behavior
- [features/nixos/wsl.nix](./features/nixos/wsl.nix) owns the common WSL system feature
- [nixosModules/corporate-ca.nix](./nixosModules/corporate-ca.nix) owns CA trust wiring
- [flake.nix](./flake.nix) now exports the `nix-community` cache via `nixConfig`, so `--accept-flake-config` can substitute Neovim nightly instead of source-building it
- `workwsl` now reuses the desktop SOPS password hash and expects the personal age key at `~/.config/sops/age/keys.txt`
- `wslbootstrap` keeps passwordless sudo for first-boot convenience; `workwsl` does not
- [flake/checks.nix](./flake/checks.nix) now includes explicit `workwsl`, `wslbootstrap`, and `wslbootstrap` tarball-builder checks

The remaining work is operational, not structural.

## File-by-File Refactor Plan

### 1. [flake.nix](./flake.nix)

Add the `nixos-wsl` input.

Planned change:

- add `nixos-wsl.url = "github:nix-community/NixOS-WSL";`
- set `inputs.nixpkgs.follows = "nixpkgs"` for that input

Reason:

- the host should import `inputs.nixos-wsl.nixosModules.default`

### 2. [flake/hosts.nix](./flake/hosts.nix)

Add two more host entries: `wslbootstrap` and `workwsl`.

Planned change:

- keep `desktop` as-is
- add `flake.nixosConfigurations.wslbootstrap = inputs.nixpkgs.lib.nixosSystem { ... }`
- add `flake.nixosConfigurations.workwsl = inputs.nixpkgs.lib.nixosSystem { ... }`
- import `../hosts/wslbootstrap`
- import `../hosts/workwsl`

Reason:

- the minimal published image and the real WSL host should be separate artifacts

### 3. [nixosModules/base.nix](./nixosModules/base.nix)

This split is implemented.

Result:

- new `nixosModules/core.nix` replacement for shared host logic
- new `nixosModules/desktop-services.nix` for desktop-only services

Move into `core.nix`:

- `repo.*` option definitions
- assertions
- `nix.settings.experimental-features`
- `nixpkgs.config.allowUnfree`
- `nixpkgs.config.permittedInsecurePackages`
- `programs.nh`
- `services.openssh`
- timezone and locale
- shell defaults
- SOPS wiring
- primary user creation
- Home Manager integration
- `home-manager.backupFileExtension`

Move out of core into `desktop-services.nix`:

- `networking.networkmanager.enable`
- `services.avahi`
- `services.printing`
- `programs.system-config-printer`
- `services.pipewire`
- `security.rtkit`
- `services.xserver.xkb`
- `programs.firefox.enable`

Reason:

- `workwsl` needs the common user/Home Manager/SOPS/Nix behavior
- `workwsl` must not inherit desktop networking, audio, mDNS, printing, or browser policy from core

### 4. [features/nixos/base.nix](./features/nixos/base.nix)

This feature now points at shared system composition only.

Planned change:

- import the new `../../nixosModules/core.nix`
- keep shared system package wiring only if it is actually host-neutral

Reason:

- `features/nixos/base.nix` should become safe for both `desktop` and `workwsl`

### 5. [nixosModules/packages.nix](./nixosModules/packages.nix)

This split is implemented.

Current problem:

- it still installs `xwayland-satellite` and `repoPackages.desktop`
- `repoPackages.desktop` includes `ventoy-full-gtk`, CUDA, NVIDIA tooling, and `vscode`

Planned result:

- keep only minimal system-wide packages here, or rename it to `core-packages.nix`
- add a new `nixosModules/desktop-packages.nix` for:
  - `xwayland-satellite`
  - `repoPackages.desktop`
  - any other display-machine-only packages

Reason:

- `workwsl` should not inherit Linux desktop packages at the system layer

### 6. [users/home.nix](./users/home.nix)

This is now the desktop user entrypoint instead of the only user entrypoint.

Planned change:

- keep desktop-specific imports here:
  - `inputs.noctalia.homeModules.default`
  - `../features/home-manager/desktop-wayland.nix`
  - `../features/home-manager/terminal-ghostty.nix`
- move the shared imports into a new common file

Reason:

- WSL should not inherit Wayland, Noctalia, or Ghostty assumptions

### 7. [users/common.nix](./users/common.nix)

Create a shared Home Manager user entrypoint.

Planned imports:

- `inputs.nix-index-database.homeModules.default`
- `inputs.nixvim.homeModules.nixvim`
- `../features/home-manager/base.nix`
- `../features/home-manager/shell.nix`
- `../features/home-manager/developer.nix`

Reason:

- both `desktop` and `workwsl` should share the common shell, editor, packages, and developer setup

### 8. [users/workwsl.nix](./users/workwsl.nix)

Create the WSL-specific Home Manager entrypoint.

Planned imports:

- `./common.nix`

Optional later additions:

- a WSL-specific terminal module if Windows Terminal or another terminal needs host-specific behavior
- remote-editor support only if there is a concrete workflow need

Do not import:

- `desktop-wayland.nix`
- `terminal-ghostty.nix`
- `inputs.noctalia.homeModules.default`

Reason:

- WSL is not a Wayland desktop session

### 9. `users/wslbootstrap.nix`

Create a minimal bootstrap user entrypoint only if Home Manager is actually needed for the bootstrap image.

Preferred path:

- avoid a Home Manager user module entirely for `wslbootstrap`

Fallback path if a user-level shell baseline is required:

- keep it minimal and terminal-only
- no editor setup
- no developer tooling
- no desktop integrations

Reason:

- the published bootstrap image should stay as small and neutral as possible

### 10. [features/nixos/wsl.nix](./features/nixos/wsl.nix)

Create a dedicated WSL system feature.

Planned contents:

- import `inputs.nixos-wsl.nixosModules.default`
- `wsl.enable = true`
- `wsl.interop.includePath = false`
- `wsl.startMenuLaunchers = false`
- `security.sudo.wheelNeedsPassword = false`

Reason:

- WSL-specific behavior should live in a dedicated feature bundle, not in the host file directly

### 11. [hosts/wslbootstrap/default.nix](./hosts/wslbootstrap/default.nix)

Create a minimal WSL bootstrap host for release publishing.

Planned shape:

- import:
  - `../../features/nixos/wsl.nix`
- set:
  - `networking.hostName = "wslbootstrap"`
  - `wsl.defaultUser = repo.user.username`
  - `system.stateVersion = "<chosen version>"`
- include only certificate trust and whatever user/default shell state is required for first login
- use `repo.workNetwork.certificateFile` via [nixosModules/corporate-ca.nix](./nixosModules/corporate-ca.nix)

Do not add:

- repo CLI package bundles
- Home Manager desktop features
- `nixvim`
- `tmux`
- Kubernetes, cloud, media, or language tool bundles

Reason:

- this image exists only to get a working trusted WSL base onto the laptop

### 12. [hosts/workwsl/default.nix](./hosts/workwsl/default.nix)

Create the new host entrypoint.

Planned shape:

- do not import `hardware-configuration.nix`
- import:
  - `../../features/nixos/base.nix`
  - `../../features/nixos/wsl.nix`
- set:
  - `networking.hostName = "workwsl"`
  - `wsl.defaultUser = repo.user.username`
  - `repo.user.homeModule = ../../users/workwsl.nix`
  - `programs.nix-ld.enable = true`
  - `repo.obsidian.enable = false`
  - `repo.secrets.sopsFile = null`
- `system.stateVersion = "<chosen version>"`

Reason:

- `workwsl` is the right place to declare terminal-first host defaults

### 13. Local `zscaler.pem` plus GitHub secret `ZSCALER_PEM`

Provide the corporate CA in two places:

- local desktop file for validation:
  - exported as `ZSCALER_PEM_FILE=/path/to/zscaler.pem`
- GitHub repository secret:
  - `ZSCALER_PEM`

Reason:

- this must work before the first useful network fetch
- this is trust material, not a password or API secret

### 14. [.github/workflows/release-wsl-bootstrap.yml](./.github/workflows/release-wsl-bootstrap.yml)

Create a release workflow that publishes the minimal `wslbootstrap` image.

Workflow design:

- trigger on:
  - `workflow_dispatch`
  - optionally tags like `wslbootstrap-*`
- build target:
  - `.#nixosConfigurations.wslbootstrap.config.system.build.tarballBuilder`
- run the produced builder to emit `nixos.wsl`
- upload the `.wsl` file as a release asset

Important scope limit:

- this workflow should publish only the minimal bootstrap image
- it should not include repo tooling, terminal tooling, or the real `workwsl` host payload

Naming suggestion:

- release title: `wslbootstrap`
- asset name: `nixos-wsl-bootstrap-x86_64-linux.wsl`

Important prerequisite:

- this only works if `ZSCALER_PEM` is present as a GitHub secret

Reason:

- the work laptop then has a stable, downloadable, trust-ready base image before the full host exists locally

### 15. [README.md](./README.md)

Update the repo README after implementation.

Planned additions:

- change current scope from one host to two hosts
- document `workwsl` as a planned or supported host
- add the WSL bootstrap commands
- link this plan file until the implementation is complete

## Bootstrap Sequence

This is the recommended end-to-end flow from the current repo state.

### Phase A: Desktop-side refactor

1. Keep the existing `nixos-wsl` input locked.
2. Keep the existing core versus desktop split.
3. Keep `wslbootstrap` and `workwsl` as separate hosts.
4. Set `ZSCALER_PEM` in GitHub.
5. Keep a local `zscaler.pem` for desktop-side validation when needed.

Validation after this phase:

```bash
nix build --no-link .#nixosConfigurations.desktop.config.system.build.toplevel --accept-flake-config --impure
ZSCALER_PEM_FILE=/path/to/zscaler.pem nix build --no-link .#nixosConfigurations.wslbootstrap.config.system.build.toplevel --accept-flake-config --impure
ZSCALER_PEM_FILE=/path/to/zscaler.pem nix build --no-link .#nixosConfigurations.workwsl.config.system.build.toplevel --accept-flake-config --impure
```

### Phase B: Publish the bootstrap image

Use the minimal `wslbootstrap` host for publishing.

Planned flow:

```bash
sudo env ZSCALER_PEM_FILE=/path/to/zscaler.pem nix run .#nixosConfigurations.wslbootstrap.config.system.build.tarballBuilder --accept-flake-config --impure
```

Expected result:

- a `nixos.wsl` image file in the working directory
- later, the same output can be produced in GitHub Actions and attached to a release

Keep a local copy of:

- the built `nixos.wsl`
- this repo checkout

### Phase C: Install the bootstrap image on the work laptop

From an elevated PowerShell or Windows Terminal session:

```powershell
wsl --install --from-file .\nixos.wsl --name workwsl
```

If a custom installation directory is needed:

```powershell
wsl --install --from-file .\nixos.wsl --name workwsl --location D:\WSL\workwsl
```

Then start it:

```powershell
wsl -d workwsl
```

### Phase D: Validate trust before cloning

Run these inside the newly installed WSL instance:

```bash
curl -I https://cache.nixos.org
git ls-remote https://github.com/PyDataBlog/nixos-config.git
nix flake metadata github:nix-community/NixOS-WSL
```

If these fail with certificate errors, stop and fix trust before trying to clone anything else.

### Phase E: Clone the repo inside WSL

Clone into the Linux filesystem, not under `/mnt/c`.

Example:

```bash
cd ~
git clone https://github.com/PyDataBlog/nixos-config.git
cd nixos-config
```

If SSH is preferred and the work environment allows it:

```bash
git clone git@github.com:PyDataBlog/nixos-config.git
```

### Phase F: First on-device rebuild to the real host

From the repo root inside WSL:

```bash
sudo nixos-rebuild switch --flake .#workwsl --accept-flake-config --impure --log-format bar-with-logs
```

Optional richer progress view:

```bash
sudo -v
nix shell nixpkgs#nix-output-monitor -c bash -lc 'sudo nixos-rebuild switch --flake .#workwsl --accept-flake-config --impure --log-format raw |& nom'
```

`wslbootstrap` persists the active corporate CA at `/var/lib/nixos-config/corporate-ca.pem`, so the first `workwsl` switch can reuse that host-local copy without re-passing `ZSCALER_PEM_FILE`.

Then restart the distro if required:

```powershell
wsl -t workwsl
wsl -d workwsl
```

## Work PC Checklist

This is the practical install-to-convergence sequence for the work laptop after the bootstrap image has been published.

### 1. Download and install the bootstrap image

In Windows PowerShell:

```powershell
wsl --install --from-file .\nixos-wsl-bootstrap-x86_64-linux.wsl --name workwsl
```

If WSL is already installed and the command fails, update or enable WSL first and rerun the same install command.

### 2. Boot into the bootstrap distro

In Windows PowerShell:

```powershell
wsl -d workwsl
```

### 3. Verify TLS trust before cloning anything

Run these inside WSL:

```bash
whoami
curl -I https://cache.nixos.org
git ls-remote https://github.com/PyDataBlog/nixos-config.git
```

Expected result:

- the user is `bebr`
- both network commands succeed without certificate errors

If any TLS error appears here, stop and fix trust before cloning the repo.

### 4. Restore the personal age key

`workwsl` reuses the desktop password hash from `secrets/desktop.yaml`, so the personal age key must exist before switching to the real host.

Run inside WSL:

```bash
mkdir -p ~/.config/sops/age
cp /path/to/backup/keys.txt ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
```

### 5. Clone the repo into the Linux filesystem

Do not use `/mnt/c/...`.

```bash
cd ~
git clone https://github.com/PyDataBlog/nixos-config.git
cd nixos-config
```

If GitHub CLI is needed before switching to `workwsl`, pull it in ephemerally instead of baking it into `wslbootstrap`:

```bash
nix shell nixpkgs#gh
```

For a one-off command:

```bash
nix shell nixpkgs#gh -c gh auth status
```

### 6. Switch to the real `workwsl` host

Run inside the repo:

```bash
sudo nixos-rebuild switch --flake .#workwsl --accept-flake-config --impure --log-format bar-with-logs
```

Optional richer progress view:

```bash
sudo -v
nix shell nixpkgs#nix-output-monitor -c bash -lc 'sudo nixos-rebuild switch --flake .#workwsl --accept-flake-config --impure --log-format raw |& nom'
```

Behavior note:

- `wslbootstrap` has passwordless sudo
- `workwsl` requires the normal password again
- `wslbootstrap` persists the active corporate CA at `/var/lib/nixos-config/corporate-ca.pem`, so later on-device rebuilds can reuse that local copy without the PEM env
- the activation path now re-applies the declarative password hash after user management if `/etc/shadow` did not pick it up on the first switch

### 7. Restart the distro once

In Windows PowerShell:

```powershell
wsl -t workwsl
wsl -d workwsl
```

### 8. Verify the final state

Run inside WSL:

```bash
whoami
echo $SHELL
tmux -V
nvim --version | head
sudo -v
```

Expected result:

- the shell stack is present
- `sudo -v` prompts for the normal password instead of behaving like bootstrap mode

### 9. Optional full validation pass

Run inside the repo:

```bash
nix flake check --accept-flake-config --impure
```

If this fails after the host switch succeeds, the remaining issue is repo-level rather than bootstrap-level.

## First-Pass Host Defaults

These are the recommended initial defaults for `workwsl`.

- `repo.obsidian.enable = false`
- `repo.secrets.sopsFile = ../../secrets/desktop.yaml`
- `repo.secrets.userPasswordHashKey = "user-password-hash"`
- `sops.age.keyFile = "/home/bebr/.config/sops/age/keys.txt"`
- terminal-first packages and workflows only
- no desktop features
- no Wayland features
- no Noctalia
- no Ghostty-specific Home Manager module
- no Linux GUI apps by default
- no clipboard-manager or desktop MIME integration by default
- Docker integration only if work actually requires it

Reason:

- the first successful WSL host should optimize for trust, shell, tmux, Neovim, CLI tooling, and rebuildability
- GUI and desktop extras should be justified separately instead of arriving by inheritance from `desktop`
- reusing the existing hashed password avoids a separate password bootstrap path once the personal age key is restored

## Secrets Strategy for WSL

Do not make host secrets part of the first `workwsl` bootstrap unless they are actually needed.

Recommended initial state:

- no WSL host secret file
- no host SSH key based SOPS identity
- no dependency on the work laptop for secret decryption during first boot

If secrets are needed later:

- prefer personal age identity based access over host SSH key coupling
- add a separate `secrets/workwsl.yaml` only when there is a concrete need

## Suggested Implementation Order

This order keeps the risk low.

1. split `users/home.nix` into `users/common.nix` plus desktop-only `users/home.nix`
2. split `nixosModules/base.nix` into core and desktop services
3. split `nixosModules/packages.nix` into core and desktop package layers
4. add `features/nixos/wsl.nix`
5. add `hosts/wslbootstrap/default.nix`
6. add the certificate file and trust wiring
7. build and test `.#nixosConfigurations.wslbootstrap.config.system.build.toplevel`
8. add the release workflow for the bootstrap image
9. add `users/workwsl.nix` and `hosts/workwsl/default.nix`
10. build and test `.#nixosConfigurations.workwsl.config.system.build.toplevel`
11. publish or copy the bootstrap `nixos.wsl`
12. install on the work laptop

## Completion Criteria

The `workwsl` work is done when all of these are true:

- `ZSCALER_PEM_FILE=/path/to/zscaler.pem nix build --no-link .#nixosConfigurations.wslbootstrap.config.system.build.toplevel --accept-flake-config --impure` succeeds on the desktop
- `ZSCALER_PEM_FILE=/path/to/zscaler.pem nix build --no-link .#nixosConfigurations.workwsl.config.system.build.toplevel --accept-flake-config --impure` succeeds on the desktop
- the published or locally built bootstrap WSL image installs successfully
- the new WSL instance can reach GitHub and `cache.nixos.org` without TLS errors
- the repo can be cloned inside WSL without temporary certificate hacks
- `sudo nixos-rebuild switch --flake .#workwsl --accept-flake-config --impure --log-format bar-with-logs` succeeds on the work laptop
- the first interactive shell has the expected terminal-first environment:
  - `nu`
  - `tmux`
  - `nvim`
  - the portable CLI tooling needed for daily work
