{
  inputs,
  lib,
  pkgs,
  system,
  pkgsStable,
}:
let
  shellPath = lib.getExe pkgs.nushell;
  baseNixvim = inputs.nixvim.legacyPackages.${system}.makeNixvimWithModule {
    inherit pkgs;
    extraSpecialArgs = {
      inherit inputs pkgsStable;
    };
    module = {
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
      --set SHELL "${shellPath}"
  '';
}
