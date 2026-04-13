{
  inputs,
  lib,
  osConfig,
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
  home.packages =
    repoPackages.cli
    ++ repoPackages.cloudOps
    ++ repoPackages.mediaDocs
    ++ repoPackages.languages
    ++ repoPackages.kubernetes
    ++ lib.optionals osConfig.repo.obsidian.enable repoPackages.notes
    ++ [
      repoPackages.lfWrapped
    ];
}
