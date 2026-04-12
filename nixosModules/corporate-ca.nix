{ config, lib, ... }:
let
  envPemFile = builtins.getEnv "ZSCALER_PEM_FILE";
  envPemPath =
    if envPemFile == "" then
      null
    else
      builtins.path {
        path = envPemFile;
        name = "corporate-ca.pem";
      };
  caBundlePath = "/etc/ssl/certs/ca-bundle.crt";
in
{
  options.repo.workNetwork.certificateFile = lib.mkOption {
    type = lib.types.nullOr lib.types.path;
    default = envPemPath;
    description = "Optional corporate CA PEM file used to trust outbound TLS interception on the work network.";
  };

  config = lib.mkIf (config.repo.workNetwork.certificateFile != null) {
    security.pki.certificateFiles = [ config.repo.workNetwork.certificateFile ];

    nix.settings.ssl-cert-file = caBundlePath;

    environment.sessionVariables = {
      NIX_SSL_CERT_FILE = caBundlePath;
      SSL_CERT_FILE = caBundlePath;
    };
  };
}
