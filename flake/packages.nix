{ inputs, repoLib, ... }:
{
  perSystem =
    { system, ... }:
    let
      pkgs = repoLib.mkPkgs {
        inherit system;
      };
      pkgsStable = repoLib.mkPkgsStable system;
      nixvim = import ../wrappers/nixvim.nix {
        inherit inputs pkgs system;
        lib = pkgs.lib;
        inherit pkgsStable;
      };
      cli = import ../wrappers/cli.nix {
        inherit inputs pkgs system pkgsStable;
      };
      nvimApp = {
        type = "app";
        program = "${nixvim}/bin/nvim";
        meta.description = "Portable standalone Nixvim build from this flake";
      };
      cliApp = {
        type = "app";
        program = "${cli}/bin/portable-cli";
        meta.description = "Portable standalone CLI environment from this flake";
      };
    in
    {
      packages = {
        inherit cli nixvim;
        default = nixvim;
      };

      apps = {
        cli = cliApp;
        nixvim = nvimApp;
        default = nvimApp;
      };
    };
}
