{ inputs, ... }:
{
  imports = [
    ./common.nix
    inputs.noctalia.homeModules.default
    ../homeManagerModules/emacs.nix
    ../features/home-manager/desktop-wayland.nix
    ../features/home-manager/terminal-ghostty.nix
  ];
}
