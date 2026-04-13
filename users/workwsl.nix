{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [ ./common.nix ];

  programs.nixvim = {
    nixpkgs.pkgs = lib.mkForce pkgs;
    package = lib.mkForce inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
  };
}
