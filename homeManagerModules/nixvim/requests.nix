{ pkgs, ... }:
{
  extraPlugins = with pkgs.vimPlugins; [ kulala-nvim ];

  extraConfigLuaPost = ''
    require('kulala').setup({
      global_keymaps = false,
      global_keymaps_prefix = '<Leader>r',
      kulala_keymaps_prefix = "",
    })
  '';
}
