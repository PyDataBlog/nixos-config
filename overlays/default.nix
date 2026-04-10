{ inputs }:
{
  default = _final: _prev: { };
  neovim-nightly = import ./neovim-nightly.nix { inherit inputs; };
}
