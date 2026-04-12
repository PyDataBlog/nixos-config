{ pkgs }:
let
  lib = pkgs.lib;
in
pkgs.writeShellApplication {
  name = "jj";
  runtimeInputs = [
    pkgs.jujutsu
  ];
  text = ''
    exec ${lib.getExe pkgs.jujutsu} "$@"
  '';
}
