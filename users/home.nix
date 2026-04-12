{ inputs, ... }:
{
  imports = [
    ./common.nix
    inputs.noctalia.homeModules.default
    ../features/home-manager/desktop-wayland.nix
    ../features/home-manager/terminal-ghostty.nix
  ];
}
