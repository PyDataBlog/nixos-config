{ pkgs, ... }:
{
  extraPlugins = with pkgs.vimPlugins; [
    markdown-preview-nvim
    render-markdown-nvim
  ];

  extraConfigLuaPost = ''
    vim.g.mkdp_filetypes = { 'markdown' }

    local ok_render_markdown, render_markdown = pcall(require, 'render-markdown')
    if ok_render_markdown then
      render_markdown.setup({
        file_types = { 'markdown', 'norg', 'org', 'rmd', 'codecompanion' },
        code = {
          sign = false,
          width = 'block',
          right_pad = 1,
        },
        heading = {
          sign = false,
          icons = {},
        },
        checkbox = {
          enabled = false,
        },
      })
    end
  '';
}
