{ pkgs, ... }:
{
  extraPlugins = with pkgs.vimPlugins; [
    plenary-nvim
    codecompanion-nvim
    codecompanion-history-nvim
    sidekick-nvim
  ];
}
