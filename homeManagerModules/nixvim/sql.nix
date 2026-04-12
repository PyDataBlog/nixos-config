{ pkgs, ... }:
{
  extraPlugins = with pkgs.vimPlugins; [
    vim-dadbod
    vim-dadbod-completion
    vim-dadbod-ui
  ];
}
