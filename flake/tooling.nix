{ ... }:
{
  perSystem =
    { config, ... }:
    {
      treefmt = {
        projectRootFile = "flake.nix";
        programs.nixfmt.enable = true;
      };

      pre-commit = {
        settings.hooks = {
          treefmt.enable = true;
          deadnix.enable = true;
        };
      };

      devShells.default = config.pre-commit.devShell;
    };
}
