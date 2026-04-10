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
    inputs.treefmt-nix.flakeModule
    inputs.git-hooks.flakeModule
    ./hosts.nix
    ./packages.nix
    ./overlays.nix
    ./checks.nix
    ./tooling.nix
  ];

  flake.lib = repoLib;
}
