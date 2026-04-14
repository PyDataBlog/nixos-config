{
  config,
  lib,
  pkgs,
  ...
}:
let
  envPem = builtins.getEnv "ZSCALER_PEM";
  envPemFile = builtins.getEnv "ZSCALER_PEM_FILE";
  explicitCertificateFile = config.repo.workNetwork.certificateFile;
  persistedCertificateFile = config.repo.workNetwork.persistedCertificateFile;
  persistedCertificatePath = config.repo.workNetwork.persistedCertificatePath;
  envPemFilePath =
    if envPemFile == "" then
      null
    else if builtins.pathExists envPemFile then
      builtins.path {
        path = envPemFile;
        name = "corporate-ca.pem";
      }
    else
      throw "ZSCALER_PEM_FILE points to a missing file: ${envPemFile}";
  envPemPath = if envPem != "" then builtins.toFile "corporate-ca.pem" envPem else envPemFilePath;
  activeCertificateFile =
    if explicitCertificateFile != null then
      explicitCertificateFile
    else if envPemPath != null then
      envPemPath
    else
      persistedCertificateFile;
  caBundlePath = config.security.pki.caBundle;
in
{
  options.repo.workNetwork = {
    certificateFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Explicit corporate CA PEM file to use for this host.";
    };

    extendNixpkgsCacert = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether derivation-time fetchers should trust the active corporate CA via nixpkgs cacert.";
    };

    persistedCertificateFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default =
        if builtins.pathExists persistedCertificatePath then
          builtins.path {
            path = persistedCertificatePath;
            name = "corporate-ca-persisted.pem";
          }
        else
          null;
      description = "Persisted corporate CA PEM already present on the host.";
    };

    persistedCertificatePath = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/nixos-config/corporate-ca.pem";
      description = "Absolute host path where the active corporate CA PEM is persisted.";
    };
  };

  config = lib.mkIf (activeCertificateFile != null) (
    lib.mkMerge [
      {
        security.pki.certificateFiles = [ activeCertificateFile ];

        nix.settings.ssl-cert-file = caBundlePath;

        environment.variables = {
          AWS_CA_BUNDLE = caBundlePath;
          CURL_CA_BUNDLE = caBundlePath;
          GIT_SSL_CAINFO = caBundlePath;
          NIX_GIT_SSL_CAINFO = caBundlePath;
          NIX_SSL_CERT_FILE = caBundlePath;
          NODE_EXTRA_CA_CERTS = caBundlePath;
          REQUESTS_CA_BUNDLE = caBundlePath;
          SSL_CERT_FILE = caBundlePath;
        };

        system.activationScripts.persistCorporateCa = {
          supportsDryActivation = true;
          text = ''
            if [ "$NIXOS_ACTION" = dry-activate ]; then
              echo "would persist corporate CA to ${persistedCertificatePath}"
            else
              ${pkgs.coreutils}/bin/install -Dm0644 ${activeCertificateFile} ${lib.escapeShellArg persistedCertificatePath}
            fi
          '';
        };
      }
      (lib.mkIf config.repo.workNetwork.extendNixpkgsCacert {
        nixpkgs.overlays = lib.mkBefore [
          (_: prev: {
            cacert = prev.cacert.override {
              extraCertificateFiles = [ activeCertificateFile ];
            };
          })
        ];
      })
    ]
  );
}
