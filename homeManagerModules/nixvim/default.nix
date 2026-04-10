{ inputs, pkgs, ... }:
let
  kubectlPlugin = inputs.kubectl-nvim.packages.${pkgs.stdenv.hostPlatform.system}.kubectl-nvim;
  claudeCodePkg = inputs.claude-code-nix.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;
  codexPkg = inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.codex;
in
{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    enableMan = true;
    viAlias = true;
    vimAlias = true;
    imports = [ ./shared.nix ];
    _module.args = {
      inherit claudeCodePkg codexPkg kubectlPlugin;
    };
    nixpkgs.pkgs = pkgs.extend (import ../../overlays/neovim-nightly.nix { inherit inputs; });
  };
}
