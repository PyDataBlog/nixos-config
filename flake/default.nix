{ inputs, ... }:
let
  repoLib = import ../lib { inherit inputs; };
in
{
  systems = [ repoLib.defaultSystem ];

  _module.args = {
    inherit repoLib;
  };

  imports = [
    ./hosts.nix
    ./packages.nix
    ./overlays.nix
    ./checks.nix
  ];

  flake.lib = repoLib;
}
