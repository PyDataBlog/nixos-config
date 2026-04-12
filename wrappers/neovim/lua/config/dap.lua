local ok_dap, dap = pcall(require, "dap")
if not ok_dap then
  return
end

local prompt_args = function(label)
  local input = vim.fn.input(label or "Arguments: ")
  if input == nil or input == "" then
    return {}
  end
  return vim.split(input, "%s+", { trimempty = true })
end

require("dap-view").setup({
  auto_toggle = true,
})

require("nvim-dap-virtual-text").setup({
  enabled = true,
  enabled_commands = true,
  highlight_changed_variables = true,
  highlight_new_as_changed = false,
  show_stop_reason = true,
  commented = false,
  only_first_definition = true,
  all_references = false,
  clear_on_continue = false,
  virt_text_pos = vim.fn.has("nvim-0.10") == 1 and "inline" or "eol",
  all_frames = false,
  virt_lines = false,
})

require("dap-python").setup(vim.fn.exepath("debugpy-adapter"), {
  include_configs = true,
  console = "integratedTerminal",
})

require("dap-go").setup({
  delve = {
    path = vim.fn.exepath("dlv"),
    detached = vim.fn.has("win32") == 0,
  },
})

dap.adapters.lldb = {
  type = "executable",
  command = vim.fn.exepath("lldb-dap"),
  name = "lldb",
}

local lldb_config = {
  {
    name = "Launch executable",
    type = "lldb",
    request = "launch",
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
    program = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    args = function()
      return prompt_args("Arguments: ")
    end,
  },
}

if vim.tbl_isempty(dap.configurations.rust or {}) then
  dap.configurations.rust = vim.deepcopy(lldb_config)
end
dap.configurations.zig = vim.deepcopy(lldb_config)

local python_configs = dap.configurations.python or {}
dap.configurations.python = python_configs
table.insert(python_configs, {
  type = "python",
  request = "launch",
  name = "Django: runserver",
  program = "${workspaceFolder}/manage.py",
  args = { "runserver", "--noreload" },
  django = true,
  justMyCode = false,
  console = "integratedTerminal",
})

local signs = {
  DapBreakpoint = { text = "●", texthl = "DiagnosticError" },
  DapBreakpointCondition = { text = "◆", texthl = "DiagnosticWarn" },
  DapBreakpointRejected = { text = "○", texthl = "DiagnosticHint" },
  DapLogPoint = { text = "◉", texthl = "DiagnosticInfo" },
  DapStopped = { text = "▶", texthl = "DiagnosticOk", linehl = "CursorLine" },
}

for name, opts in pairs(signs) do
  vim.fn.sign_define(name, opts)
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "dap-view", "dap-view-help", "dap-view-term", "dap-repl" },
  callback = function(ev)
    vim.keymap.set("n", "q", "<C-w>q", { buffer = ev.buf, desc = "Close debug window" })
  end,
  desc = "Close DAP windows with q",
})
