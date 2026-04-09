{ lib, pkgs, ... }:
{
  extraPlugins = with pkgs.vimPlugins; [
    pkgs.vimPlugins."FixCursorHold-nvim"
    neotest
    neotest-bash
    neotest-go
    neotest-python
    neotest-rust
    neotest-zig
    nvim-nio
  ];

  extraConfigLuaPost = lib.mkAfter ''
    local neotest = require('neotest')
    local bashunit = vim.fn.exepath('bashunit')
    local adapters = {
      require('neotest-python')({
        dap = {
          justMyCode = false,
          console = 'integratedTerminal',
        },
      }),
      require('neotest-go')({
        recursive_run = true,
        experimental = {
          test_table = true,
        },
        args = { '-count=1', '-timeout=60s' },
      }),
      require('neotest-rust')({
        dap_adapter = 'lldb',
      }),
      require('neotest-zig')({
        dap = { adapter = 'lldb' },
      }),
    }

    local bash_opts = {}
    if bashunit ~= "" then
      bash_opts.executable = bashunit
    end
    table.insert(adapters, require('neotest-bash')(bash_opts))

    neotest.setup({
      floating = {
        border = 'single',
        max_height = 0.85,
        max_width = 0.85,
      },
      running = {
        concurrent = true,
      },
      adapters = adapters,
      summary = {
        count = true,
        follow = true,
        expand_errors = true,
        open = 'botright vsplit | vertical resize 42',
      },
      output = {
        open_on_run = 'short',
      },
      output_panel = {
        open = 'botright split | resize 12',
      },
      diagnostic = {
        enabled = true,
        severity = vim.diagnostic.severity.ERROR,
      },
      status = {
        enabled = true,
        signs = true,
        virtual_text = false,
      },
      quickfix = {
        enabled = false,
      },
    })
  '';
}
