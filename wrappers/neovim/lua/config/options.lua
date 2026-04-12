vim.g.mapleader = " "
vim.g.maplocalleader = ","

local options = {
  autoindent = true,
  breakindent = true,
  breakindentopt = "list:-1",
  clipboard = "unnamedplus",
  colorcolumn = "+1",
  complete = ".,w,b,kspell",
  completeopt = "menuone,noselect,fuzzy,nosort",
  completetimeout = 100,
  cursorline = true,
  cursorlineopt = "screenline,number",
  expandtab = true,
  foldcolumn = "1",
  foldlevel = 10,
  foldlevelstart = 10,
  foldmethod = "indent",
  foldnestmax = 10,
  foldtext = "",
  formatlistpat = "^\\s*[0-9\\-\\+\\*]\\+[\\.\\)]*\\s\\+",
  formatoptions = "rqnl1j",
  ignorecase = true,
  incsearch = true,
  infercase = true,
  iskeyword = "@,48-57,_,192-255,-",
  laststatus = 3,
  linebreak = true,
  list = false,
  mouse = "a",
  mousescroll = "ver:25,hor:6",
  number = true,
  pumborder = "single",
  pumheight = 10,
  pummaxwidth = 100,
  relativenumber = true,
  ruler = false,
  scrolloff = 8,
  shada = "'100,<50,s10,:1000,/100,@100,h",
  showmode = false,
  shiftwidth = 2,
  shortmess = "CFOSWaco",
  sidescrolloff = 8,
  signcolumn = "yes",
  smartcase = true,
  smartindent = true,
  softtabstop = 2,
  spelloptions = "camel",
  splitbelow = true,
  splitkeep = "screen",
  splitright = true,
  switchbuf = "usetab",
  tabstop = 2,
  termguicolors = true,
  timeoutlen = 300,
  updatetime = 200,
  undofile = true,
  virtualedit = "block",
  winborder = "single",
  wrap = false,
}

for option, value in pairs(options) do
  vim.opt[option] = value
end

vim.opt.fillchars = {
  eob = " ",
  fold = "╌",
  foldclose = "+",
  foldinner = " ",
  foldopen = "-",
  foldsep = " ",
}

vim.opt.listchars = {
  extends = "…",
  nbsp = "␣",
  precedes = "…",
  tab = "> ",
}

vim.cmd.colorscheme("miniwinter")
vim.cmd("filetype plugin indent on")

if vim.fn.exists("syntax_on") ~= 1 then
  vim.cmd("syntax enable")
end

vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "o" })
  end,
  desc = "Proper formatoptions",
})

if vim.env.NIXVIM_SHELL ~= nil and vim.env.NIXVIM_SHELL ~= "" then
  vim.o.shell = vim.env.NIXVIM_SHELL
end

vim.diagnostic.config({
  signs = {
    priority = 9999,
    severity = {
      min = vim.diagnostic.severity.WARN,
      max = vim.diagnostic.severity.ERROR,
    },
  },
  underline = {
    severity = {
      min = vim.diagnostic.severity.HINT,
      max = vim.diagnostic.severity.ERROR,
    },
  },
  virtual_lines = false,
  virtual_text = {
    current_line = true,
    severity = {
      min = vim.diagnostic.severity.ERROR,
      max = vim.diagnostic.severity.ERROR,
    },
  },
  update_in_insert = false,
})
