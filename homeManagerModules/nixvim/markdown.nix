{ pkgs, ... }:
{
  extraPlugins = with pkgs.vimPlugins; [
    markdown-preview-nvim
    render-markdown-nvim
  ];
}
