{ inputs, ... }:
{
  imports = [
    inputs.nix-index-database.homeModules.default
    inputs.nixvim.homeModules.nixvim
    ../features/home-manager/base.nix
    ../features/home-manager/shell.nix
    ../features/home-manager/developer.nix
  ];
}
