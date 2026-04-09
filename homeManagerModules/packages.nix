{
  inputs,
  pkgs,
  pkgsStable,
  ...
}:
let
  repoPackages = import ../packages {
    inherit pkgs pkgsStable;
  };
in
{
  home.packages = repoPackages.cli ++ repoPackages.desktop;
}
