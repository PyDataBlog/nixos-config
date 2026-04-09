{ inputs, repoLib, ... }:
let
  system = repoLib.defaultSystem;
in
{
  flake.nixosConfigurations.desktop = inputs.nixpkgs.lib.nixosSystem {
    inherit system;

    specialArgs = {
      inherit inputs repoLib;
      pkgsStable = repoLib.mkPkgsStable system;
    };

    modules = [ ../hosts/desktop ];
  };
}
