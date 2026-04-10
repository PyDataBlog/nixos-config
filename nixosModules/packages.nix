{ inputs, pkgs, ... }:
let
  repoPackages = import ../packages {
    inherit pkgs;
    claudeCodePkg = inputs.claude-code-nix.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;
    codexPkg = inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.codex;
  };
in
{
  environment.systemPackages =
    (with pkgs; [
      git
      vim
      wget
      docker-compose
      xwayland-satellite
    ])
    ++ repoPackages.desktop;
}
