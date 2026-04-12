{ pkgs, ... }:
{
  extraPlugins = with pkgs.vimPlugins; [ overseer-nvim ];
}
