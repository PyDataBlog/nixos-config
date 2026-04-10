{ inputs, ... }:
{
  imports = [
    inputs.nix-index-database.homeModules.default
    inputs.nixvim.homeModules.nixvim
    inputs.noctalia.homeModules.default
    ../features/home-manager/base.nix
    ../features/home-manager/desktop-wayland.nix
    ../features/home-manager/shell.nix
    ../features/home-manager/terminal-ghostty.nix
    ../features/home-manager/developer.nix
  ];
}
