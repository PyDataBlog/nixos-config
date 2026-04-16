{ inputs, ... }:
{
  imports = [
    inputs.nix-index-database.homeModules.default
    inputs.nixvim.homeModules.nixvim
    inputs.noctalia.homeModules.default
    ../homeManagerModules/core.nix
    ../homeManagerModules/obsidian.nix
    ../homeManagerModules/packages.nix
    ../homeManagerModules/shell.nix
    ../homeManagerModules/nixvim/default.nix
    ../homeManagerModules/emacs.nix
    ../homeManagerModules/base.nix
    ../homeManagerModules/clipboard.nix
    ../homeManagerModules/mimeapps.nix
    ../homeManagerModules/obsidian-desktop.nix
    ../homeManagerModules/ghostty.nix
  ];
}
