{ pkgs }:
let
  lib = pkgs.lib;
in
pkgs.writeShellApplication {
  name = "qalc";
  runtimeInputs = [
    pkgs.gnuplot
    pkgs.libqalculate
  ];
  text = ''
    exec ${lib.getExe pkgs.libqalculate} "$@"
  '';
}
