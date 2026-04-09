{ ... }:
let
  mkCmdMap =
    mode: key: cmd: desc:
    {
      inherit mode key;
      action = "<cmd>${cmd}<cr>";
      options.desc = desc;
    };

  mkLuaMap =
    mode: key: lua: desc:
    {
      inherit mode key;
      action.__raw = lua;
      options.desc = desc;
    };

  mkCmdNmap = mkCmdMap "n";
  mkLuaNmap = mkLuaMap "n";
  mkLuaXmap = mkLuaMap "x";
in
{
  keymaps = [
    (mkCmdNmap "<C-s>" "write" "Save")
    (mkCmdNmap "<Esc>" "nohlsearch" "Clear search highlight")
    (mkCmdNmap "[p" ''exe "iput! " . v:register'' "Paste above")
    (mkCmdNmap "]p" ''exe "iput "  . v:register'' "Paste below")
    (
      mkLuaNmap "<leader>aa" "function() require('sidekick.cli').toggle({ name = 'codex', focus = true }) end"
        "Sidekick Codex"
    )
    (mkCmdNmap "<leader>aC" "CodeCompanionActions" "AI actions")
    (mkCmdNmap "<leader>ac" "CodeCompanionChat Toggle" "Toggle AI chat")
    (mkCmdNmap "<leader>ah" "CodeCompanionHistory" "AI chat history")
    (mkCmdNmap "<leader>ai" "CodeCompanion" "Inline AI prompt")
    (
      mkLuaNmap "<leader>ad" "function() require('sidekick.cli').close() end"
        "Close Sidekick CLI"
    )
    (
      mkLuaNmap "<leader>af" "function() require('sidekick.cli').send({ msg = '{file}' }) end"
        "Send file to Sidekick"
    )
    (
      mkLuaNmap "<leader>aj" "function() require('sidekick').nes_jump_or_apply() end"
        "NES jump/apply"
    )
    (
      mkLuaNmap "<leader>aN" "function() require('sidekick.nes').update() end"
        "Refresh NES"
    )
    (
      mkLuaNmap "<leader>an" "function() require('sidekick.nes').toggle() end"
        "Toggle NES"
    )
    (
      mkLuaNmap "<leader>ap" "function() require('sidekick.cli').prompt() end"
        "Prompt Sidekick CLI"
    )
    (
      mkLuaNmap "<leader>as" "function() require('sidekick.cli').select({ filter = { installed = true } }) end"
        "Select Sidekick CLI"
    )
    (
      mkLuaNmap "<leader>at" "function() require('sidekick.cli').send({ msg = '{this}' }) end"
        "Send current context"
    )
    (
      mkLuaNmap "<leader>ax" "function() require('sidekick.nes').clear() end"
        "Clear NES suggestion"
    )
    (mkCmdNmap "<leader>qw" "q" "Quit window")
    (mkCmdNmap "<leader>qq" "qa" "Quit all")
    (mkCmdNmap "<leader>qr" "restart" "Restart Neovim")
    (mkCmdNmap "<leader>qx" "x" "Write and quit")
    (mkCmdNmap "<leader>ba" "b#" "Alternate buffer")
    (mkLuaNmap "<leader>bd" "function() MiniBufremove.delete() end" "Delete buffer")
    (mkLuaNmap "<leader>bD" "function() MiniBufremove.delete(0, true) end" "Delete buffer forcefully")
    (
      mkLuaNmap "<leader>bo" ''
        function()
          local current = vim.api.nvim_get_current_buf()
          for _, info in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
            if info.bufnr ~= current then
              MiniBufremove.delete(info.bufnr)
            end
          end
        end
      '' "Delete other buffers"
    )
    (
      mkLuaNmap "<leader>bO" ''
        function()
          local current = vim.api.nvim_get_current_buf()
          for _, info in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
            if info.bufnr ~= current then
              MiniBufremove.delete(info.bufnr, true)
            end
          end
        end
      '' "Delete other buffers forcefully"
    )
    (
      mkLuaNmap "<leader>bs" "function() vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(true, true)) end"
        "Scratch buffer"
    )
    (mkLuaNmap "<leader>bw" "function() MiniBufremove.wipeout() end" "Wipe out buffer")
    (mkLuaNmap "<leader>bW" "function() MiniBufremove.wipeout(0, true) end" "Wipe out buffer forcefully")
    (mkLuaNmap "<leader>e" "function() MiniFiles.open() end" "Open file explorer")
    (mkLuaNmap "<leader>ed" "function() MiniFiles.open() end" "Explore current working directory")
    (
      mkLuaNmap "<leader>ef" "function() MiniFiles.open(vim.api.nvim_buf_get_name(0)) end"
        "Explore current file directory"
    )
    (mkLuaNmap "<leader>en" "function() MiniNotify.show_history() end" "Show notifications")
    (
      mkLuaNmap "<leader>eq" ''
        function()
          local winid = vim.fn.getqflist({ winid = true }).winid
          vim.cmd(winid ~= 0 and 'cclose' or 'copen')
        end
      '' "Toggle quickfix list"
    )
    (
      mkLuaNmap "<leader>eQ" ''
        function()
          local winid = vim.fn.getloclist(0, { winid = true }).winid
          vim.cmd(winid ~= 0 and 'lclose' or 'lopen')
        end
      '' "Toggle location list"
    )
    (mkCmdNmap "<leader>f/" "Pick history scope=\"/\"" "Search history")
    (mkCmdNmap "<leader>f:" "Pick history scope=\":\"" "Command history")
    (mkCmdNmap "<leader>fa" "Pick git_hunks scope=\"staged\"" "Added hunks")
    (mkCmdNmap "<leader>fA" "Pick git_hunks path=\"%\" scope=\"staged\"" "Added hunks in buffer")
    (mkCmdNmap "<leader>fb" "Pick buffers" "Find buffers")
    (mkCmdNmap "<leader>fc" "Pick git_commits" "Find commits")
    (mkCmdNmap "<leader>fC" "Pick git_commits path=\"%\"" "Find buffer commits")
    (mkCmdNmap "<leader>fd" "Pick diagnostic scope=\"all\"" "Workspace diagnostics")
    (mkCmdNmap "<leader>fD" "Pick diagnostic scope=\"current\"" "Buffer diagnostics")
    (mkCmdNmap "<leader>ff" "Pick files" "Find files")
    (mkCmdNmap "<leader>fg" "Pick grep_live" "Live grep")
    (mkCmdNmap "<leader>fG" "Pick grep pattern=\"<cword>\"" "Grep current word")
    (mkCmdNmap "<leader>fh" "Pick help" "Find help tags")
    (mkCmdNmap "<leader>fH" "Pick hl_groups" "Find highlight groups")
    (mkCmdNmap "<leader>fl" "Pick buf_lines scope=\"all\"" "Find lines")
    (mkCmdNmap "<leader>fL" "Pick buf_lines scope=\"current\"" "Find buffer lines")
    (mkCmdNmap "<leader>fm" "Pick git_hunks" "Modified hunks")
    (mkCmdNmap "<leader>fM" "Pick git_hunks path=\"%\"" "Modified hunks in buffer")
    (mkCmdNmap "<leader>fr" "Pick resume" "Resume picker")
    (mkCmdNmap "<leader>fR" "Pick lsp scope=\"references\"" "LSP references")
    (mkCmdNmap "<leader>fs" "Pick lsp scope=\"workspace_symbol_live\"" "Workspace symbols")
    (mkCmdNmap "<leader>fS" "Pick lsp scope=\"document_symbol\"" "Document symbols")
    (mkCmdNmap "<leader>fv" "Pick visit_paths cwd=\"\"" "Visited paths")
    (mkCmdNmap "<leader>fV" "Pick visit_paths" "Visited paths in cwd")
    (mkCmdNmap "<leader>gg" "TermToggleLazygit" "Lazygit toggle")
    (mkCmdNmap "<leader>ga" "Git diff --cached" "Git diff staged")
    (mkCmdNmap "<leader>gA" "Git diff --cached -- %" "Git diff staged buffer")
    (mkCmdNmap "<leader>gc" "Git commit" "Git commit")
    (mkCmdNmap "<leader>gC" "Git commit --amend" "Git amend")
    (mkCmdNmap "<leader>gd" "Git diff" "Git diff")
    (mkCmdNmap "<leader>gD" "Git diff -- %" "Git diff buffer")
    (mkCmdNmap "<leader>gl" "Git log --pretty=format:\\%h\\ \\%as\\ │\\ \\%s --topo-order" "Git log")
    (
      mkCmdNmap "<leader>gL" "Git log --pretty=format:\\%h\\ \\%as\\ │\\ \\%s --topo-order --follow -- %"
        "Git log buffer"
    )
    (mkLuaNmap "<leader>go" "function() MiniDiff.toggle_overlay() end" "Toggle diff overlay")
    (mkLuaNmap "<leader>gs" "function() MiniGit.show_at_cursor() end" "Show git info")
    (mkLuaNmap "<leader>db" "function() require('dap').toggle_breakpoint() end" "Toggle breakpoint")
    (
      mkLuaNmap "<leader>dB"
        "function() require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: ')) end"
        "Set conditional breakpoint"
    )
    (mkLuaNmap "<leader>dc" "function() require('dap').continue() end" "Continue debugging")
    (mkLuaNmap "<leader>de" "function() require('dap.ui.widgets').hover() end" "Evaluate expression")
    (mkLuaNmap "<leader>dg" "function() require('dap-go').debug_test() end" "Debug nearest Go test")
    (mkLuaNmap "<leader>dG" "function() require('dap-go').debug_last_test() end" "Debug last Go test")
    (mkLuaNmap "<leader>di" "function() require('dap').step_into() end" "Step into")
    (mkLuaNmap "<leader>dm" "function() require('dap-python').test_method() end" "Debug Python test method")
    (mkLuaNmap "<leader>dM" "function() require('dap-python').test_class() end" "Debug Python test class")
    (mkLuaNmap "<leader>do" "function() require('dap').step_over() end" "Step over")
    (mkLuaNmap "<leader>dO" "function() require('dap').step_out() end" "Step out")
    (mkLuaNmap "<leader>dp" "function() require('dap').pause() end" "Pause debugging")
    (mkLuaNmap "<leader>dq" "function() require('dap').repl.toggle() end" "Toggle DAP REPL")
    (mkLuaNmap "<leader>dr" "function() require('dap').run_last() end" "Run last debug config")
    (mkLuaNmap "<leader>dt" "function() require('dap').terminate() end" "Terminate debugging")
    (mkCmdNmap "<leader>du" "DapViewToggle" "Toggle debug UI")
    (mkCmdNmap "<leader>dv" "DapVirtualTextToggle" "Toggle debug virtual text")
    (mkCmdNmap "<leader>dw" "DapViewWatch" "Watch expression")
    (mkLuaNmap "<leader>dx" "function() require('dap').clear_breakpoints() end" "Clear breakpoints")
    (
      mkLuaNmap "<leader>dL"
        "function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end"
        "Set log point"
    )
    (mkLuaNmap "<leader>la" "function() vim.lsp.buf.code_action() end" "Actions")
    (
      mkLuaNmap "<leader>lf" "function() require('conform').format({ async = true, lsp_format = 'fallback' }) end"
        "Format buffer"
    )
    (
      mkLuaNmap "<leader>lG" ''
        function()
          local lint = require('lint')
          if lint.linters.gitleaks == nil then
            vim.notify('gitleaks linter is not available in nvim-lint', vim.log.levels.WARN)
            return
          end
          lint.try_lint('gitleaks')
        end
      '' "Run Gitleaks"
    )
    (mkLuaNmap "<leader>lh" "function() vim.lsp.buf.hover() end" "Hover")
    (mkLuaNmap "<leader>li" "function() vim.lsp.buf.implementation() end" "Implementation")
    (mkLuaNmap "<leader>ll" "function() require('lint').try_lint() end" "Lint buffer")
    (mkLuaNmap "<leader>lL" "function() vim.lsp.codelens.run() end" "Run code lens")
    (mkLuaNmap "<leader>lr" "function() vim.lsp.buf.rename() end" "Rename")
    (mkLuaNmap "<leader>lR" "function() vim.lsp.buf.references() end" "References")
    (mkLuaNmap "<leader>ls" "function() vim.lsp.buf.definition() end" "Source definition")
    (mkLuaNmap "<leader>lt" "function() vim.lsp.buf.type_definition() end" "Type definition")
    (mkLuaNmap "<leader>mf" "function() MiniMap.toggle_focus() end" "Toggle map focus")
    (mkLuaNmap "<leader>mr" "function() MiniMap.refresh() end" "Refresh map")
    (mkLuaNmap "<leader>ms" "function() MiniMap.toggle_side() end" "Toggle map side")
    (mkLuaNmap "<leader>mt" "function() MiniMap.toggle() end" "Toggle map")
    (mkLuaNmap "<leader>na" "function() require('neotest').run.attach() end" "Attach to running test")
    (mkLuaNmap "<leader>nd" "function() require('neotest').run.run({ strategy = 'dap' }) end" "Debug nearest test")
    (mkLuaNmap "<leader>nf" "function() require('neotest').run.run(vim.fn.expand('%')) end" "Run test file")
    (mkLuaNmap "<leader>nl" "function() require('neotest').run.run_last() end" "Run last test")
    (mkLuaNmap "<leader>nn" "function() require('neotest').run.run() end" "Run nearest test")
    (
      mkLuaNmap "<leader>no" "function() require('neotest').output.open({ enter = true, auto_close = true }) end"
        "Open test output"
    )
    (mkLuaNmap "<leader>nO" "function() require('neotest').output_panel.toggle() end" "Toggle test output panel")
    (mkLuaNmap "<leader>nq" "function() require('neotest').run.stop() end" "Stop test run")
    (mkLuaNmap "<leader>ns" "function() require('neotest').summary.toggle() end" "Toggle test summary")
    (mkLuaNmap "<leader>nS" "function() require('neotest').run.run(vim.fn.getcwd()) end" "Run test suite")
    (mkLuaNmap "<leader>nw" "function() require('neotest').watch.toggle(vim.fn.expand('%')) end" "Watch test file")
    (mkCmdNmap "<leader>oa" "OverseerTaskAction" "Overseer task action")
    (mkCmdNmap "<leader>oo" "OverseerToggle! right" "Toggle Overseer task list")
    (mkCmdNmap "<leader>or" "OverseerRun" "Run Overseer task")
    (mkCmdNmap "<leader>oR" "OverseerRestartLast" "Restart last Overseer task")
    (mkCmdNmap "<leader>os" "OverseerShell" "Run shell task")
    (mkLuaNmap "<leader>ot" "function() MiniTrailspace.trim() end" "Trim trailing whitespace")
    (mkLuaNmap "<leader>ow" "function() MiniMisc.resize_window() end" "Resize to default width")
    (mkLuaNmap "<leader>oz" "function() MiniMisc.zoom() end" "Toggle zoom")
    (mkLuaNmap "<leader>sd" "function() MiniSessions.select('delete') end" "Delete session")
    (
      mkLuaNmap "<leader>sn" "function() vim.ui.input({ prompt = 'Session name: ' }, MiniSessions.write) end"
        "New session"
    )
    (mkLuaNmap "<leader>sr" "function() MiniSessions.select('read') end" "Read session")
    (mkLuaNmap "<leader>sR" "function() MiniSessions.restart() end" "Restart into session")
    (mkLuaNmap "<leader>sw" "function() MiniSessions.write() end" "Write current session")
    (mkCmdNmap "<leader>tt" "TermToggleVertical" "Toggle vertical terminal")
    (mkCmdNmap "<leader>tT" "TermToggleHorizontal" "Toggle horizontal terminal")
    (mkCmdNmap "<leader>tf" "TermToggleFloat" "Toggle floating terminal")
    (mkCmdNmap "<leader>tg" "TermToggleLazygit" "Toggle Lazygit")
    (mkCmdNmap "<leader>tl" "TermToggleLast" "Toggle last terminal")
    (
      mkLuaNmap "<leader>vc" ''
        function()
          local sort_latest = MiniVisits.gen_sort.default({ recency_weight = 1 })
          MiniExtra.pickers.visit_paths(
            { cwd = "", filter = 'core', sort = sort_latest },
            { source = { name = 'Core visits (all)' } }
          )
        end
      '' "Core visits"
    )
    (
      mkLuaNmap "<leader>vC" ''
        function()
          local sort_latest = MiniVisits.gen_sort.default({ recency_weight = 1 })
          MiniExtra.pickers.visit_paths(
            { filter = 'core', sort = sort_latest },
            { source = { name = 'Core visits (cwd)' } }
          )
        end
      '' "Core visits in cwd"
    )
    (mkLuaNmap "<leader>vl" "function() MiniVisits.add_label() end" "Add visit label")
    (mkLuaNmap "<leader>vL" "function() MiniVisits.remove_label() end" "Remove visit label")
    (mkLuaNmap "<leader>vv" "function() MiniVisits.add_label('core') end" "Add core visit label")
    (mkLuaNmap "<leader>vV" "function() MiniVisits.remove_label('core') end" "Remove core visit label")
    {
      mode = "n";
      key = "(";
      action = "gxiagxila";
      options = {
        desc = "Swap argument left";
        remap = true;
      };
    }
    {
      mode = "n";
      key = ")";
      action = "gxiagxina";
      options = {
        desc = "Swap argument right";
        remap = true;
      };
    }
    {
      mode = "x";
      key = "<leader>lf";
      action.__raw = "function() require('conform').format({ async = true, lsp_format = 'fallback' }) end";
      options.desc = "Format selection";
    }
    (mkCmdMap "x" "<leader>aC" "CodeCompanionActions" "AI actions")
    (mkCmdMap "x" "<leader>ac" "CodeCompanionChat Add" "Add selection to AI chat")
    (
      mkLuaXmap "<leader>av" "function() require('sidekick.cli').send({ msg = '{selection}' }) end"
        "Send selection to Sidekick"
    )
    (mkLuaXmap "<leader>ds" "function() require('dap-python').debug_selection() end" "Debug selection")
    (mkLuaXmap "<leader>gs" "function() MiniGit.show_at_cursor() end" "Show git info")
  ];
}
