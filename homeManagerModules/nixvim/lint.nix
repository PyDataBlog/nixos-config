{ pkgs, ... }:
{
  extraPlugins = [ pkgs.vimPlugins."nvim-lint" ];
}
