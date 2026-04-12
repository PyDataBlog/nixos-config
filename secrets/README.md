<!--toc:start-->

- [Secrets](#secrets)
<!--toc:end-->

## Secrets

This repo uses `sops-nix` for host secrets.

Typical password bootstrap flow for a new host:

```bash
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

Important:

- Git-backed flakes do not see untracked files
- stage the encrypted `secrets/<host>.yaml` before building
