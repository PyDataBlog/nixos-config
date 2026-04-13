{ pkgs, ... }:
let
  emacsPkg = import ../wrappers/emacs.nix { inherit pkgs; };
in
{
  home.packages = [ emacsPkg ];
}
