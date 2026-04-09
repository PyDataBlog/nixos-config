## Secrets

This repo uses `sops-nix` for host secrets.

Typical password bootstrap flow for a new host:

```bash
# Convert the host SSH public key into an age recipient
ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub

# Generate a password hash
mkpasswd

# Edit the encrypted host secrets file
sops secrets/<host>.yaml
```

Example encrypted payload:

```yaml
user-password-hash: "$y$j9T$..."
```

Then point the host config at it:

```nix
{
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  repo.secrets = {
    sopsFile = ../../secrets/<host>.yaml;
    userPasswordHashKey = "user-password-hash";
  };
}
```
