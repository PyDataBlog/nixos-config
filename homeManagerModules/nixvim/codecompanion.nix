{ lib, pkgs, ... }:
{
  extraPlugins = with pkgs.vimPlugins; [
    plenary-nvim
    codecompanion-nvim
    codecompanion-history-nvim
    sidekick-nvim
  ];

  extraConfigLuaPost = lib.mkAfter ''
    require("codecompanion").setup({
      display = {
        action_palette = {
          provider = "mini_pick",
          opts = {
            title = "AI actions",
            show_preset_actions = true,
            show_preset_prompts = true,
          },
        },
        chat = {
          show_header_separator = false,
          show_settings = false,
        },
      },
      interactions = {
        chat = {
          adapter = "copilot",
          opts = {
            completion_provider = "default",
          },
          slash_commands = {
            ["buffer"] = {
              opts = {
                provider = "mini_pick",
              },
            },
            ["file"] = {
              opts = {
                provider = "mini_pick",
              },
            },
            ["help"] = {
              opts = {
                provider = "mini_pick",
              },
            },
          },
        },
        inline = {
          adapter = "copilot",
        },
        cmd = {
          adapter = "copilot",
        },
      },
      adapters = {
        http = {
          opts = {
            show_model_choices = true,
          },
        },
      },
      extensions = {
        history = {
          enabled = true,
          opts = {
            keymap = "gh",
            auto_generate_title = true,
            continue_last_chat = false,
            delete_on_clearing_chat = false,
            picker = "default",
            enable_logging = false,
            dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
          },
        },
      },
    })

    local has_trigger_prefix = function()
      local line = vim.api.nvim_get_current_line()
      local col = vim.api.nvim_win_get_cursor(0)[2]
      local prefix = line:sub(1, col):match('%S+$')
      return prefix ~= nil and prefix:match('^[#/@]') ~= nil
    end

    vim.api.nvim_create_autocmd('User', {
      pattern = 'CodeCompanionChatCreated',
      callback = function(args)
        local bufnr = args.data.bufnr

        vim.keymap.set('i', '<Tab>', function()
          if vim.fn.pumvisible() == 1 then
            return '<C-n>'
          end
          if has_trigger_prefix() then
            return '<C-x><C-o>'
          end
          return '<Tab>'
        end, { buffer = bufnr, expr = true, desc = 'AI completion next' })

        vim.keymap.set('i', '<S-Tab>', function()
          if vim.fn.pumvisible() == 1 then
            return '<C-p>'
          end
          return '<S-Tab>'
        end, { buffer = bufnr, expr = true, desc = 'AI completion previous' })

        vim.keymap.set('i', '<CR>', function()
          if vim.fn.pumvisible() == 1 then
            return '<C-y>'
          end
          return '<CR>'
        end, { buffer = bufnr, expr = true, desc = 'AI completion confirm' })
      end,
    })

    require("sidekick").setup({
      cli = {
        mux = {
          enabled = true,
          backend = "tmux",
          create = "terminal",
        },
        win = {
          layout = "right",
          split = {
            width = 88,
            height = 20,
          },
        },
      },
    })
  '';
}
