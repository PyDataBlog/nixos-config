{ inputs, repoLib, ... }:
let
  system = repoLib.defaultSystem;
  mkHost =
    module:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit inputs repoLib;
        pkgsStable = repoLib.mkPkgsStable system;
      };

      modules = [ module ];
    };
in
{
  flake.nixosConfigurations.desktop = mkHost ../hosts/desktop;
  flake.nixosConfigurations.workwsl = mkHost ../hosts/workwsl;
  flake.nixosConfigurations.wslbootstrap = mkHost ../hosts/wslbootstrap;
}
