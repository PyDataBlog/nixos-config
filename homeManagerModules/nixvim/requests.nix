{ pkgs, ... }:
{
  extraPlugins = with pkgs.vimPlugins; [ kulala-nvim ];
}
