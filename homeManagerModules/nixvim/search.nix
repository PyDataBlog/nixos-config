{ pkgs, ... }:
let
  upstream = pkgs.vimPlugins.grug-far-nvim;
  grugFarPlugin = pkgs.vimUtils.buildVimPlugin {
    pname = upstream.pname;
    version = upstream.version;
    src = upstream.src;
  };
in
{
  extraPlugins = [ grugFarPlugin ];
}
