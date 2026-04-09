{ inputs, pkgs, ... }:
{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    enableMan = true;
    viAlias = true;
    vimAlias = true;
    imports = [ ./shared.nix ];
    nixpkgs.pkgs = pkgs.extend (import ../../overlays/neovim-nightly.nix { inherit inputs; });
  };
}
