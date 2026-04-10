{
  inputs,
  lib,
  pkgs,
  system,
  pkgsStable,
}:
let
  shellPath = lib.getExe pkgs.nushell;
  kubectlPlugin = inputs.kubectl-nvim.packages.${pkgs.stdenv.hostPlatform.system}.kubectl-nvim;
  claudeCodePkg = inputs.claude-code-nix.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;
  codexPkg = inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.codex;
  baseNixvim = inputs.nixvim.legacyPackages.${system}.makeNixvimWithModule {
    inherit pkgs;
    extraSpecialArgs = {
      inherit inputs pkgsStable;
    };
    module = {
      _module.args = {
        inherit claudeCodePkg codexPkg kubectlPlugin;
      };
      imports = [ ../homeManagerModules/nixvim/shared.nix ];
      nixpkgs.overlays = [ (import ../overlays/neovim-nightly.nix { inherit inputs; }) ];
    };
  };
in
pkgs.symlinkJoin {
  name = "nixvim";
  paths = [ baseNixvim ];
  nativeBuildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    wrapProgram "$out/bin/nvim" \
      --set NIXVIM_SHELL "${shellPath}" \
      --set SHELL "${shellPath}" \
      --set UV_NO_MANAGED_PYTHON 1 \
      --set UV_PYTHON_DOWNLOADS never
  '';
}
