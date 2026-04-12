{ pkgs, ... }:
let
  presentermNvim = pkgs.vimUtils.buildVimPlugin {
    pname = "presenterm-nvim";
    version = "2026-04-08";
    src = pkgs.fetchFromGitHub {
      owner = "Piotr1215";
      repo = "presenterm.nvim";
      rev = "610ad9e44abbcff3fe41c71f14e42622b4f9a6f7";
      hash = "sha256-Hw6Lw1CfJcrlMuCi16WHior6EeJqXJ7S+aMfIg29HWk=";
    };
  };
in
{
  extraPlugins = [
    pkgs.vimPlugins."vim-tmux-navigator"
    presentermNvim
  ];
}
