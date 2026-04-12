{ pkgs, ... }:
{
  extraPlugins = [
    pkgs.vimPlugins."conform-nvim"
    pkgs.vimPlugins."nvim-lspconfig"
    pkgs.vimPlugins."SchemaStore-nvim"
    pkgs.vimPlugins."lazydev-nvim"
    pkgs.vimPlugins."vim-helm"
  ];
}
