{ pkgs, ... }:
{
  extraPlugins = [
    pkgs.vimPlugins."SchemaStore-nvim"
    pkgs.vimPlugins."lazydev-nvim"
    pkgs.vimPlugins."vim-helm"
  ];

  plugins.conform-nvim = {
    enable = true;
    autoInstall = {
      enable = true;
      overrides = {
        djlint = pkgs.djlint;
        gofumpt = pkgs.gofumpt;
        golines = pkgs.golines;
        gosimports = pkgs.gosimports;
        "markdown-toc" = pkgs.markdown-toc;
        "markdownlint-cli2" = pkgs.markdownlint-cli2;
        nixfmt = pkgs.nixfmt;
        prettierd = pkgs.prettierd;
        prettier = pkgs.prettier;
        ruff_fix = pkgs.ruff;
        ruff_format = pkgs.ruff;
        ruff_organize_imports = pkgs.ruff;
        rustfmt = pkgs.rustfmt;
        shfmt = pkgs.shfmt;
        sqlfluff = pkgs.sqlfluff;
        stylua = pkgs.stylua;
        taplo = pkgs.taplo;
        terraform_fmt = pkgs.terraform;
        zigfmt = pkgs.zig;
      };
    };

    settings = {
      default_format_opts = {
        lsp_format = "fallback";
        timeout_ms = 3000;
      };
      formatters = {
        sqlfluff = {
          args = [
            "format"
            "--dialect=ansi"
            "-"
          ];
          require_cwd = false;
        };
        gosimports.command = "gosimports";
        "markdown-toc".condition.__raw = ''
          function(_, ctx)
            for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
              if line:find("<!%-%- toc %-%->") then
                return true
              end
            end
            return false
          end
        '';
        "markdownlint-cli2".condition.__raw = ''
          function(_, ctx)
            local diagnostics = vim.tbl_filter(function(diagnostic)
              return diagnostic.source == 'markdownlint'
            end, vim.diagnostic.get(ctx.buf))
            return #diagnostics > 0
          end
        '';
      };
      format_on_save = {
        lsp_format = "fallback";
        timeout_ms = 3000;
      };
      formatters_by_ft = {
        bash = [ "shfmt" ];
        css = {
          __unkeyed-1 = "prettierd";
          __unkeyed-2 = "prettier";
          stop_after_first = true;
        };
        go = [
          "gosimports"
          "gofumpt"
          "golines"
        ];
        graphql = {
          __unkeyed-1 = "prettierd";
          __unkeyed-2 = "prettier";
          stop_after_first = true;
        };
        html = {
          __unkeyed-1 = "prettierd";
          __unkeyed-2 = "prettier";
          stop_after_first = true;
        };
        htmldjango = [ "djlint" ];
        javascript = {
          __unkeyed-1 = "prettierd";
          __unkeyed-2 = "prettier";
          stop_after_first = true;
        };
        javascriptreact = {
          __unkeyed-1 = "prettierd";
          __unkeyed-2 = "prettier";
          stop_after_first = true;
        };
        json = {
          __unkeyed-1 = "prettierd";
          __unkeyed-2 = "prettier";
          stop_after_first = true;
        };
        lua = [ "stylua" ];
        markdown = {
          __unkeyed-1 = "prettierd";
          __unkeyed-2 = "markdownlint-cli2";
          __unkeyed-3 = "markdown-toc";
        };
        mysql = [ "sqlfluff" ];
        nix = [ "nixfmt" ];
        plsql = [ "sqlfluff" ];
        python = [
          "ruff_organize_imports"
          "ruff_fix"
          "ruff_format"
        ];
        rust = [ "rustfmt" ];
        sh = [ "shfmt" ];
        sql = [ "sqlfluff" ];
        terraform = [ "terraform_fmt" ];
        "terraform-vars" = [ "terraform_fmt" ];
        toml = [ "taplo" ];
        typescript = {
          __unkeyed-1 = "prettierd";
          __unkeyed-2 = "prettier";
          stop_after_first = true;
        };
        typescriptreact = {
          __unkeyed-1 = "prettierd";
          __unkeyed-2 = "prettier";
          stop_after_first = true;
        };
        yaml = {
          __unkeyed-1 = "prettierd";
          __unkeyed-2 = "prettier";
          stop_after_first = true;
        };
        "yaml.docker-compose" = {
          __unkeyed-1 = "prettierd";
          __unkeyed-2 = "prettier";
          stop_after_first = true;
        };
        "yaml.helm-values" = {
          __unkeyed-1 = "prettierd";
          __unkeyed-2 = "prettier";
          stop_after_first = true;
        };
        zig = [ "zigfmt" ];
        zsh = [ "shfmt" ];
      };
      notify_no_formatters = false;
    };
  };

  plugins.lsp = {
    capabilities = ''
      capabilities = vim.tbl_deep_extend(
        "force",
        capabilities,
        require("mini.completion").get_lsp_capabilities()
      )
    '';
    enable = true;
    inlayHints = false;
    onAttach = ''
      vim.bo[bufnr].omnifunc = "v:lua.MiniCompletion.completefunc_lsp"
    '';

    keymaps = {
      silent = true;
      diagnostic = {
        "[d" = "goto_prev";
        "]d" = "goto_next";
        "<leader>ld" = "open_float";
        "<leader>lq" = "setloclist";
      };
      lspBuf = { };
    };

    servers = {
      bashls.enable = true;
      copilot.enable = true;
      jsonls.enable = true;
      lua_ls = {
        enable = true;
        settings = {
          Lua = {
            diagnostics.globals = [ "vim" ];
            runtime.version = "LuaJIT";
            workspace.checkThirdParty = false;
          };
        };
      };
      nixd.enable = true;
      taplo.enable = true;
      yamlls = {
        enable = true;
        settings = {
          redhat.telemetry.enabled = false;
          yaml = {
            format.enable = true;
            keyOrdering = false;
            kubernetesCRDStore.enable = true;
            schemaStore = {
              enable = false;
              url = "";
            };
            schemas.kubernetes = [
              "**/*.k8s.yaml"
              "**/*.k8s.yml"
              "**/k8s/**/*.yaml"
              "**/k8s/**/*.yml"
              "**/kubernetes/**/*.yaml"
              "**/kubernetes/**/*.yml"
              "**/manifests/**/*.yaml"
              "**/manifests/**/*.yml"
            ];
            validate = true;
          };
        };
      };
    };
  };

  extraConfigLuaPost = ''
    local ok_lazydev, lazydev = pcall(require, 'lazydev')
    if ok_lazydev then
      lazydev.setup({
        library = {
          { path = "''${3rd}/luv/library", words = { 'vim%.uv' } },
        },
      })
    end

    local ok_schemastore, schemastore = pcall(require, 'schemastore')
    if ok_schemastore then
      vim.lsp.config('jsonls', {
        before_init = function(_, new_config)
          new_config.settings = new_config.settings or {}
          new_config.settings.json = new_config.settings.json or {}
          new_config.settings.json.schemas = new_config.settings.json.schemas or {}
          vim.list_extend(new_config.settings.json.schemas, schemastore.json.schemas())
        end,
      })

      vim.lsp.config('yamlls', {
        before_init = function(_, new_config)
          new_config.settings = new_config.settings or {}
          new_config.settings.yaml = new_config.settings.yaml or {}
          new_config.settings.yaml.schemas = vim.tbl_deep_extend(
            'force',
            new_config.settings.yaml.schemas or {},
            schemastore.yaml.schemas()
          )
        end,
      })
    end

    vim.lsp.config('marksman', {
      cmd_env = {
        DOTNET_SYSTEM_GLOBALIZATION_INVARIANT = '1',
      },
    })

    vim.lsp.config('sqls', {
      root_markers = { '.git', 'sqls.yml', 'config.yml' },
      single_file_support = true,
    })

    vim.lsp.config('ty', {
      settings = {
        ty = {
          diagnosticMode = 'workspace',
          completions = {
            autoImport = true,
          },
          inlayHints = {
            variableTypes = true,
            callArgumentNames = true,
          },
        },
      },
    })

    vim.lsp.config('typos_lsp', {
      root_markers = { '.git', 'typos.toml', '_typos.toml', '.typos.toml', 'pyproject.toml', 'Cargo.toml' },
      single_file_support = true,
    })

    vim.lsp.enable({
      'dockerls',
      'docker_compose_language_service',
      'gopls',
      'helm_ls',
      'marksman',
      'ruff',
      'rust_analyzer',
      'sqls',
      'terraformls',
      'ty',
      'typos_lsp',
      'zls',
    })

    local copilot_client = function(bufnr)
      local current = vim.lsp.get_clients({ bufnr = bufnr, name = 'copilot' })
      if #current > 0 then
        return current[1], bufnr
      end

      local any = vim.lsp.get_clients({ name = 'copilot' })
      if #any > 0 then
        return any[1], bufnr
      end
    end

    local with_copilot_client = function(callback)
      local bufnr = vim.api.nvim_get_current_buf()
      local client, client_bufnr = copilot_client(bufnr)
      if client == nil then
        vim.notify('Copilot LSP is not attached. Open a project file before signing in.', vim.log.levels.WARN)
        return
      end

      callback(client, client_bufnr)
    end

    local copilot_sign_in = function()
      with_copilot_client(function(client, bufnr)
        client:request('signIn', vim.empty_dict(), function(err, result)
          if err then
            vim.notify(err.message, vim.log.levels.ERROR)
            return
          end

          if result.command then
            local code = result.userCode
            local command = result.command
            vim.fn.setreg('+', code)
            vim.fn.setreg('*', code)

            local continue = vim.fn.confirm(
              'Copied your one-time code to clipboard.\nOpen the browser to complete the sign-in process?',
              '&Yes\n&No'
            )
            if continue == 1 then
              client:exec_cmd(command, { bufnr = bufnr }, function(cmd_err, cmd_result)
                if cmd_err then
                  vim.notify(cmd_err.message, vim.log.levels.ERROR)
                  return
                end

                if cmd_result.status == 'OK' then
                  vim.notify('Signed in as ' .. cmd_result.user .. '.')
                end
              end)
            end
          end

          if result.status == 'PromptUserDeviceFlow' then
            vim.notify('Enter your one-time code ' .. result.userCode .. ' in ' .. result.verificationUri)
          elseif result.status == 'AlreadySignedIn' then
            vim.notify('Already signed in as ' .. result.user .. '.')
          end
        end)
      end)
    end

    local copilot_sign_out = function()
      with_copilot_client(function(client)
        client:request('signOut', vim.empty_dict(), function(err, result)
          if err then
            vim.notify(err.message, vim.log.levels.ERROR)
            return
          end

          if result.status == 'NotSignedIn' then
            vim.notify('Not signed in.')
          else
            vim.notify('Signed out of Copilot.')
          end
        end)
      end)
    end

    vim.api.nvim_create_user_command('LspCopilotSignIn', copilot_sign_in, {
      desc = 'Sign in Copilot with GitHub',
    })

    vim.api.nvim_create_user_command('LspCopilotSignOut', copilot_sign_out, {
      desc = 'Sign out Copilot with GitHub',
    })

    local inlay_hints_enabled = function()
      local ok, enabled = pcall(vim.lsp.inlay_hint.is_enabled, { bufnr = 0 })
      if ok then
        return enabled
      end

      ok, enabled = pcall(vim.lsp.inlay_hint.is_enabled, 0)
      if ok then
        return enabled
      end

      ok, enabled = pcall(vim.lsp.inlay_hint.is_enabled)
      if ok then
        return enabled
      end

      return false
    end

    local set_inlay_hints = function(enabled)
      if pcall(vim.lsp.inlay_hint.enable, enabled, { bufnr = 0 }) then
        return
      end

      if pcall(vim.lsp.inlay_hint.enable, 0, enabled) then
        return
      end

      pcall(vim.lsp.inlay_hint.enable, enabled)
    end

    vim.keymap.set('n', '<leader>lH', function()
      set_inlay_hints(not inlay_hints_enabled())
    end, { desc = 'Toggle inlay hints' })

    vim.keymap.set('n', '<Tab>', function()
      if require('sidekick').nes_jump_or_apply() then
        return nil
      end

      return '<C-i>'
    end, { desc = 'Accept Copilot NES suggestion', expr = true, silent = true })

    vim.keymap.set('n', '<leader>lc', function()
      require('sidekick.nes').clear()
    end, { desc = 'Clear Copilot suggestion' })
  '';
}
