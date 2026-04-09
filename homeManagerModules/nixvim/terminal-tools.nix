{ lib, pkgs, ... }:
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

  extraConfigLuaPost = lib.mkAfter ''
    vim.g.tmux_navigator_no_mappings = 1

    local terminal_bridge = rawget(_G, 'NixvimTerminalBridge') or {
      last_shell = 'shell_vertical',
      terminals = {},
    }
    _G.NixvimTerminalBridge = terminal_bridge

    local terminal_state = terminal_bridge.terminals

    local find_visible_window = function(bufnr)
      for _, winid in ipairs(vim.fn.win_findbuf(bufnr)) do
        if vim.api.nvim_win_is_valid(winid) then
          return winid
        end
      end
    end

    local style_terminal_window = function(winid)
      vim.wo[winid].number = false
      vim.wo[winid].relativenumber = false
      vim.wo[winid].cursorline = false
      vim.wo[winid].signcolumn = 'no'
    end

    local auto_terminal_size = function(layout)
      if layout == 'horizontal' then
        return math.max(8, math.floor(vim.o.lines * 0.3))
      end

      if layout == 'vertical' then
        return math.max(90, math.floor(vim.o.columns * 0.4))
      end
    end

    local auto_float_terminal_config = function()
      local width = math.max(100, math.floor(vim.o.columns * 0.9))
      local height = math.max(24, math.floor(vim.o.lines * 0.9))

      return {
        relative = 'editor',
        border = 'rounded',
        style = 'minimal',
        width = width,
        height = height,
        row = math.floor((vim.o.lines - height) * 0.5),
        col = math.floor((vim.o.columns - width) * 0.5),
      }
    end

    local apply_terminal_window_size = function(winid, layout, size)
      if layout == 'float' then
        vim.api.nvim_win_set_config(winid, auto_float_terminal_config())
        return
      end

      if layout == 'horizontal' then
        vim.api.nvim_win_set_height(winid, size or auto_terminal_size(layout))
        return
      end

      if layout == 'vertical' then
        vim.api.nvim_win_set_width(winid, size or auto_terminal_size(layout))
      end
    end

    local open_terminal_window = function(layout, bufnr, size)
      if layout == 'float' then
        local winid = vim.api.nvim_open_win(bufnr, true, auto_float_terminal_config())
        style_terminal_window(winid)
        return winid
      end

      if layout == 'horizontal' then
        vim.cmd('botright split')
        local winid = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(winid, bufnr)
        apply_terminal_window_size(winid, layout, size)
        style_terminal_window(winid)
        return winid
      end

      vim.cmd('botright vsplit')
      local winid = vim.api.nvim_get_current_win()
      vim.api.nvim_win_set_buf(winid, bufnr)
      apply_terminal_window_size(winid, layout, size)
      style_terminal_window(winid)
      return winid
    end

    local current_shell_terminal_name = function()
      local bufnr = vim.api.nvim_get_current_buf()
      for name, state in pairs(terminal_state) do
        if state.group == 'shell' and state.bufnr == bufnr then
          return name
        end
      end
    end

    local pick_visible_shell_terminal = function()
      local last_state = terminal_state[terminal_bridge.last_shell]
      if last_state and last_state.group == 'shell' and find_visible_window(last_state.bufnr) then
        return terminal_bridge.last_shell
      end

      for name, state in pairs(terminal_state) do
        if state.group == 'shell' and find_visible_window(state.bufnr) then
          return name
        end
      end
    end

    local shell_layout_from_name = function(name)
      return (name and name:match('^shell_(.+)$')) or 'vertical'
    end

    local resize_auto_terminals = function()
      for _, state in pairs(terminal_state) do
        if state.auto_size then
          for _, winid in ipairs(vim.fn.win_findbuf(state.bufnr)) do
            if vim.api.nvim_win_is_valid(winid) then
              apply_terminal_window_size(winid, state.layout, state.layout == 'float' and nil or state.size)
            end
          end
        end
      end
    end

    terminal_bridge.toggle = function(name, opts)
      opts = opts or {}

      local state = terminal_state[name]
      if state and state.bufnr and vim.api.nvim_buf_is_valid(state.bufnr) then
        if state.group == 'shell' then
          terminal_bridge.last_shell = name
        end

        local winid = find_visible_window(state.bufnr)
        if winid then
          vim.api.nvim_win_close(winid, true)
          return
        end

        open_terminal_window(state.layout, state.bufnr, state.size)
        vim.cmd.startinsert()
        return
      end

      local layout = opts.layout or 'vertical'
      local bufnr = vim.api.nvim_create_buf(false, false)
      open_terminal_window(layout, bufnr, opts.size)

      terminal_state[name] = {
        auto_size = opts.size == nil,
        bufnr = bufnr,
        close_on_exit = opts.close_on_exit or false,
        group = opts.group,
        layout = layout,
        size = opts.size,
      }

      if opts.group == 'shell' then
        terminal_bridge.last_shell = name
      end

      vim.bo[bufnr].bufhidden = 'hide'
      vim.bo[bufnr].buflisted = false
      vim.b[bufnr].terminal_passthrough_keys = opts.passthrough_terminal_keys or false

      local cwd = type(opts.cwd) == 'function' and opts.cwd() or opts.cwd
      vim.fn.termopen(opts.cmd or vim.o.shell, {
        cwd = cwd,
        on_exit = function()
          vim.schedule(function()
            local current = terminal_state[name]
            if current and current.bufnr == bufnr and current.close_on_exit then
              for _, winid in ipairs(vim.fn.win_findbuf(bufnr)) do
                if vim.api.nvim_win_is_valid(winid) then
                  vim.api.nvim_win_close(winid, true)
                end
              end
            end

            if current and current.bufnr == bufnr then
              terminal_state[name] = nil
            end
          end)
        end,
      })
      vim.cmd.startinsert()
    end

    terminal_bridge.toggle_shell = function(layout)
      terminal_bridge.toggle('shell_' .. layout, { group = 'shell', layout = layout })
    end

    terminal_bridge.toggle_last_shell = function()
      local current_shell = current_shell_terminal_name()
      if current_shell ~= nil then
        terminal_bridge.toggle(current_shell)
        return
      end

      local visible_shell = pick_visible_shell_terminal()
      if visible_shell ~= nil then
        terminal_bridge.toggle(visible_shell)
        return
      end

      terminal_bridge.toggle_shell(shell_layout_from_name(terminal_bridge.last_shell))
    end

    terminal_bridge.toggle_lazygit = function()
      local git_root = vim.fs.root(0, { '.git' }) or vim.fs.root(vim.fn.getcwd(), { '.git' }) or vim.fn.getcwd()
      terminal_bridge.toggle('lazygit', {
        cmd = { 'lazygit' },
        close_on_exit = true,
        cwd = git_root,
        layout = 'vertical',
        passthrough_terminal_keys = true,
      })
    end

    vim.api.nvim_create_autocmd('VimResized', {
      callback = resize_auto_terminals,
      desc = 'Resize auto-sized terminals',
    })

    vim.api.nvim_create_user_command('TermToggleVertical', function()
      terminal_bridge.toggle_shell('vertical')
    end, { desc = 'Toggle vertical shell terminal' })

    vim.api.nvim_create_user_command('TermToggleHorizontal', function()
      terminal_bridge.toggle_shell('horizontal')
    end, { desc = 'Toggle horizontal shell terminal' })

    vim.api.nvim_create_user_command('TermToggleFloat', function()
      terminal_bridge.toggle_shell('float')
    end, { desc = 'Toggle floating shell terminal' })

    vim.api.nvim_create_user_command('TermToggleLast', function()
      terminal_bridge.toggle_last_shell()
    end, { desc = 'Toggle last shell terminal' })

    vim.api.nvim_create_user_command('TermToggleLazygit', function()
      terminal_bridge.toggle_lazygit()
    end, { desc = 'Toggle Lazygit terminal' })

    vim.keymap.set('i', 'jk', '<Esc>', { desc = 'Normal mode' })

    local terminal_toggle_expr = function(lhs)
      return function()
        if vim.b.terminal_passthrough_keys then
          return lhs
        end

        terminal_bridge.toggle_last_shell()
        return ""
      end
    end

    vim.keymap.set('n', '<C-_>', function()
      terminal_bridge.toggle_last_shell()
    end, { desc = 'Terminal toggle' })

    vim.keymap.set('n', '<C-/>', function()
      terminal_bridge.toggle_last_shell()
    end, { desc = 'Terminal toggle' })

    vim.keymap.set('t', '<C-_>', terminal_toggle_expr('<C-_>'), {
      desc = 'Terminal toggle',
      expr = true,
    })

    vim.keymap.set('t', '<C-/>', terminal_toggle_expr('<C-/>'), {
      desc = 'Terminal toggle',
      expr = true,
    })

    vim.keymap.set('t', 'jk', function()
      if vim.b.terminal_passthrough_keys then
        return 'jk'
      end

      return '<C-\\><C-n>'
    end, {
      desc = 'Terminal normal mode',
      expr = true,
    })

    local nmap = function(lhs, rhs, desc)
      vim.keymap.set('n', lhs, rhs, { desc = desc })
    end

    local tmap = function(lhs, direction, desc)
      vim.keymap.set('t', lhs, function()
        if vim.bo.filetype == 'fzf' or vim.b.terminal_passthrough_keys then
          return lhs
        end

        return string.format('<C-w>:<C-U>TmuxNavigate%s<CR>', direction)
      end, { desc = desc, expr = true, silent = true })
    end

    nmap('<C-h>', '<Cmd>TmuxNavigateLeft<CR>', 'Tmux/Vim left')
    nmap('<C-j>', '<Cmd>TmuxNavigateDown<CR>', 'Tmux/Vim down')
    nmap('<C-k>', '<Cmd>TmuxNavigateUp<CR>', 'Tmux/Vim up')
    nmap('<C-l>', '<Cmd>TmuxNavigateRight<CR>', 'Tmux/Vim right')
    nmap('<C-\\>', '<Cmd>TmuxNavigatePrevious<CR>', 'Tmux/Vim previous')

    tmap('<C-h>', 'Left', 'Tmux/Vim left')
    tmap('<C-j>', 'Down', 'Tmux/Vim down')
    tmap('<C-k>', 'Up', 'Tmux/Vim up')
    tmap('<C-l>', 'Right', 'Tmux/Vim right')
    tmap('<C-\\>', 'Previous', 'Tmux/Vim previous')

    require('presenterm').setup({
      default_keybindings = false,
      preview = {
        command = 'presenterm',
        presentation_preview_sync = true,
      },
      on_attach = function(bufnr)
        local map = function(lhs, rhs, desc)
          vim.keymap.set('n', lhs, rhs, { buffer = bufnr, desc = desc })
        end

        map('[s', '<Cmd>Presenterm prev<CR>', 'Previous slide')
        map(']s', '<Cmd>Presenterm next<CR>', 'Next slide')
      end,
    })
  '';
}
