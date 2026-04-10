{
  inputs,
  pkgs,
  pkgsStable,
  ...
}:
let
  repoPackages = import ../packages {
    inherit pkgs pkgsStable;
    claudeCodePkg = inputs.claude-code-nix.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;
    codexPkg = inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.codex;
  };
in
{
  home.packages = repoPackages.cli ++ repoPackages.languages ++ repoPackages.kubernetes;
}
