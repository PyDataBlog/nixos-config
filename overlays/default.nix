{ inputs }:
{
  default = final: prev: { };
  neovim-nightly = import ./neovim-nightly.nix { inherit inputs; };
}
