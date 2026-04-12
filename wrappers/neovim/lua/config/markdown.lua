vim.g.mkdp_filetypes = { "markdown" }

local ok_render_markdown, render_markdown = pcall(require, "render-markdown")
if not ok_render_markdown then
  return
end

render_markdown.setup({
  file_types = { "markdown", "norg", "org", "rmd", "codecompanion" },
  code = {
    sign = false,
    width = "block",
    right_pad = 1,
  },
  heading = {
    sign = false,
    icons = {},
  },
  checkbox = {
    enabled = false,
  },
  latex = {
    converter = { "latex2text" },
  },
})
