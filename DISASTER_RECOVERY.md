# Disaster Recovery

This repo is set up so the encrypted secrets live in Git, while decryption is
possible through:

- the machine host key
- your personal age key in `~/.config/sops/age/keys.txt`

For this repo, the most important recovery asset is:

- `~/.config/sops/age/keys.txt`

Back that file up outside the machine.

## What You Need

To recover this system after a reinstall, you need:

- the Git repository
- your backup of `~/.config/sops/age/keys.txt`

You do not need the old machine host key if your personal age key is available.

## Same Desktop Recovery

If you formatted the current desktop and want the whole system back:

1. Install base NixOS.
2. Get networking working.
3. Clone the repo.
4. Restore your personal age key:

   ```bash
   mkdir -p ~/.config/sops/age
   cp /path/to/backup/keys.txt ~/.config/sops/age/keys.txt
   chmod 600 ~/.config/sops/age/keys.txt
   ```

5. Keep using the tracked hardware file at [hardware-configuration.nix](./hosts/desktop/hardware-configuration.nix) if the hardware did not change.
6. Rebuild:

   ```bash
   sudo nixos-rebuild switch --flake .#desktop --accept-flake-config
   ```

7. Reboot.

If the host SSH key did not change, this should work directly.

## Host Key Changed After Reinstall

If `/etc/ssh/ssh_host_ed25519_key` changed during reinstall, the current
encrypted secret file from Git will still be present, but the machine recipient
inside it will be stale.

That is why the personal age key exists.

Recovery flow:

1. Restore your personal age key:

   ```bash
   mkdir -p ~/.config/sops/age
   cp /path/to/backup/keys.txt ~/.config/sops/age/keys.txt
   chmod 600 ~/.config/sops/age/keys.txt
   ```

2. Verify you can decrypt the secret as your normal user:

   ```bash
   SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt sops -d secrets/desktop.yaml
   ```

3. Compute the new host recipient:

   ```bash
   ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
   ```

4. Add the new host recipient to the secret using your personal key:

   ```bash
   SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt sops rotate -i --add-age <new-host-age-recipient> secrets/desktop.yaml
   ```

5. Rebuild:

   ```bash
   sudo nixos-rebuild switch --flake .#desktop --accept-flake-config
   ```

At that point, the machine can decrypt secrets again through its new host key.

## If You Lose `keys.txt`

If you lose your personal age key backup, recovery falls back to the machine
host key path only.

That means you would need the old host key material to keep decrypting the
tracked secrets after a reinstall.

So the practical backup rule is simple:

- keep the repo in Git
- keep `keys.txt` outside the machine

That is enough for disaster recovery.
