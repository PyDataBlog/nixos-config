{
  config,
  lib,
  ...
}:
let
  envPem = builtins.getEnv "ZSCALER_PEM";
  envPemFile = builtins.getEnv "ZSCALER_PEM_FILE";
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
  caBundlePath = config.security.pki.caBundle;
in
{
  options.repo.workNetwork.certificateFile = lib.mkOption {
    type = lib.types.nullOr lib.types.path;
    default = envPemPath;
    description = "Optional corporate CA PEM file used to trust outbound TLS interception on the work network.";
  };

  config = lib.mkIf (config.repo.workNetwork.certificateFile != null) {
    nixpkgs.overlays = lib.mkBefore [
      (_: prev: {
        cacert = prev.cacert.override {
          extraCertificateFiles = [ config.repo.workNetwork.certificateFile ];
        };
      })
    ];

    security.pki.certificateFiles = [ config.repo.workNetwork.certificateFile ];

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
  };
}
