{ kubectlPlugin, ... }:
{
  extraPlugins = [ kubectlPlugin ];

  extraConfigLuaPost = ''
    require('kubectl').setup({})
  '';
}
