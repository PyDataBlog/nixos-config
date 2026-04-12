local ok_conform, conform = pcall(require, "conform")
if ok_conform then
  local markdown_has_toc = function(_, ctx)
    for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
      if line:find("<!%-%- toc %-%->") then
        return true
      end
    end
    return false
  end

  local markdown_has_lint_diagnostics = function(_, ctx)
    local diagnostics = vim.tbl_filter(function(diagnostic)
      return diagnostic.source == "markdownlint"
    end, vim.diagnostic.get(ctx.buf))
    return #diagnostics > 0
  end

  conform.setup({
    default_format_opts = {
      lsp_format = "fallback",
      timeout_ms = 3000,
    },
    format_on_save = {
      lsp_format = "fallback",
      timeout_ms = 3000,
    },
    formatters = {
      gosimports = {
        command = "gosimports",
      },
      ["markdown-toc"] = {
        condition = markdown_has_toc,
      },
      ["markdownlint-cli2"] = {
        condition = markdown_has_lint_diagnostics,
      },
      sqlfluff = {
        args = { "format", "--dialect=ansi", "-" },
        require_cwd = false,
      },
    },
    formatters_by_ft = {
      bash = { "shfmt" },
      css = { "prettierd", "prettier", stop_after_first = true },
      go = { "gosimports", "gofumpt", "golines" },
      graphql = { "prettierd", "prettier", stop_after_first = true },
      html = { "prettierd", "prettier", stop_after_first = true },
      htmldjango = { "djlint" },
      javascript = { "prettierd", "prettier", stop_after_first = true },
      javascriptreact = { "prettierd", "prettier", stop_after_first = true },
      json = { "prettierd", "prettier", stop_after_first = true },
      lua = { "stylua" },
      markdown = { "prettierd", "markdownlint-cli2", "markdown-toc" },
      mysql = { "sqlfluff" },
      nix = { "nixfmt" },
      plsql = { "sqlfluff" },
      python = { "ruff_organize_imports", "ruff_fix", "ruff_format" },
      rust = { "rustfmt" },
      sh = { "shfmt" },
      sql = { "sqlfluff" },
      terraform = { "terraform_fmt" },
      ["terraform-vars"] = { "terraform_fmt" },
      toml = { "taplo" },
      typescript = { "prettierd", "prettier", stop_after_first = true },
      typescriptreact = { "prettierd", "prettier", stop_after_first = true },
      xml = { "xmllint" },
      yaml = { "prettierd", "prettier", stop_after_first = true },
      ["yaml.docker-compose"] = { "prettierd", "prettier", stop_after_first = true },
      ["yaml.helm-values"] = { "prettierd", "prettier", stop_after_first = true },
      zig = { "zigfmt" },
      zsh = { "shfmt" },
    },
    notify_no_formatters = false,
  })
end

local ok_lazydev, lazydev = pcall(require, "lazydev")
if ok_lazydev then
  lazydev.setup({
    library = {
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
    },
  })
end

local capabilities = {}
local ok_mini_completion, mini_completion = pcall(require, "mini.completion")
if ok_mini_completion then
  capabilities = vim.tbl_deep_extend("force", capabilities, mini_completion.get_lsp_capabilities())
end

local configure = function(server, opts)
  vim.lsp.config(server, vim.tbl_deep_extend("force", {
    capabilities = capabilities,
  }, opts or {}))
end

local ok_schemastore, schemastore = pcall(require, "schemastore")
configure("jsonls", ok_schemastore and {
  before_init = function(_, new_config)
    new_config.settings = new_config.settings or {}
    new_config.settings.json = new_config.settings.json or {}
    new_config.settings.json.schemas = new_config.settings.json.schemas or {}
    vim.list_extend(new_config.settings.json.schemas, schemastore.json.schemas())
  end,
} or {})

configure("lua_ls", {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      runtime = {
        version = "LuaJIT",
      },
      workspace = {
        checkThirdParty = false,
      },
    },
  },
})

configure("marksman", {
  cmd_env = {
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT = "1",
  },
})

configure("sqls", {
  root_markers = { ".git", "sqls.yml", "config.yml" },
  single_file_support = true,
})

configure("ty", {
  settings = {
    ty = {
      diagnosticMode = "workspace",
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

configure("typos_lsp", {
  root_markers = { ".git", "typos.toml", "_typos.toml", ".typos.toml", "pyproject.toml", "Cargo.toml" },
  single_file_support = true,
})

configure("yamlls", {
  before_init = ok_schemastore and function(_, new_config)
    new_config.settings = new_config.settings or {}
    new_config.settings.yaml = new_config.settings.yaml or {}
    new_config.settings.yaml.schemas = vim.tbl_deep_extend(
      "force",
      new_config.settings.yaml.schemas or {},
      schemastore.yaml.schemas()
    )
  end or nil,
  settings = {
    redhat = {
      telemetry = {
        enabled = false,
      },
    },
    yaml = {
      format = {
        enable = true,
      },
      keyOrdering = false,
      kubernetesCRDStore = {
        enable = true,
      },
      schemaStore = {
        enable = false,
        url = "",
      },
      schemas = {
        kubernetes = {
          "**/*.k8s.yaml",
          "**/*.k8s.yml",
          "**/k8s/**/*.yaml",
          "**/k8s/**/*.yml",
          "**/kubernetes/**/*.yaml",
          "**/kubernetes/**/*.yml",
          "**/manifests/**/*.yaml",
          "**/manifests/**/*.yml",
        },
      },
      validate = true,
    },
  },
})

vim.lsp.enable({
  "bashls",
  "copilot",
  "dockerls",
  "docker_compose_language_service",
  "gopls",
  "helm_ls",
  "jsonls",
  "lua_ls",
  "marksman",
  "nixd",
  "ruff",
  "rust_analyzer",
  "sqls",
  "taplo",
  "terraformls",
  "texlab",
  "ty",
  "typos_lsp",
  "yamlls",
  "zls",
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    vim.bo[args.buf].omnifunc = "v:lua.MiniCompletion.completefunc_lsp"
  end,
  desc = "Use MiniCompletion as LSP omnifunc",
})

vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set("n", "<leader>ld", vim.diagnostic.open_float, { desc = "Line diagnostics" })
vim.keymap.set("n", "<leader>lq", vim.diagnostic.setloclist, { desc = "Diagnostics to location list" })

local copilot_client = function(bufnr)
  local current = vim.lsp.get_clients({ bufnr = bufnr, name = "copilot" })
  if #current > 0 then
    return current[1], bufnr
  end

  local any = vim.lsp.get_clients({ name = "copilot" })
  if #any > 0 then
    return any[1], bufnr
  end
end

local with_copilot_client = function(callback)
  local bufnr = vim.api.nvim_get_current_buf()
  local client, client_bufnr = copilot_client(bufnr)
  if client == nil then
    vim.notify("Copilot LSP is not attached. Open a project file before signing in.", vim.log.levels.WARN)
    return
  end

  callback(client, client_bufnr)
end

local copilot_sign_in = function()
  with_copilot_client(function(client, bufnr)
    client:request("signIn", vim.empty_dict(), function(err, result)
      if err then
        vim.notify(err.message, vim.log.levels.ERROR)
        return
      end

      if result.command then
        local code = result.userCode
        local command = result.command
        vim.fn.setreg("+", code)
        vim.fn.setreg("*", code)

        local continue = vim.fn.confirm(
          "Copied your one-time code to clipboard.\nOpen the browser to complete the sign-in process?",
          "&Yes\n&No"
        )
        if continue == 1 then
          client:exec_cmd(command, { bufnr = bufnr }, function(cmd_err, cmd_result)
            if cmd_err then
              vim.notify(cmd_err.message, vim.log.levels.ERROR)
              return
            end

            if cmd_result.status == "OK" then
              vim.notify("Signed in as " .. cmd_result.user .. ".")
            end
          end)
        end
      end

      if result.status == "PromptUserDeviceFlow" then
        vim.notify("Enter your one-time code " .. result.userCode .. " in " .. result.verificationUri)
      elseif result.status == "AlreadySignedIn" then
        vim.notify("Already signed in as " .. result.user .. ".")
      end
    end)
  end)
end

local copilot_sign_out = function()
  with_copilot_client(function(client)
    client:request("signOut", vim.empty_dict(), function(err, result)
      if err then
        vim.notify(err.message, vim.log.levels.ERROR)
        return
      end

      if result.status == "NotSignedIn" then
        vim.notify("Not signed in.")
      else
        vim.notify("Signed out of Copilot.")
      end
    end)
  end)
end

vim.api.nvim_create_user_command("LspCopilotSignIn", copilot_sign_in, {
  desc = "Sign in Copilot with GitHub",
})

vim.api.nvim_create_user_command("LspCopilotSignOut", copilot_sign_out, {
  desc = "Sign out Copilot with GitHub",
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

vim.keymap.set("n", "<leader>lH", function()
  set_inlay_hints(not inlay_hints_enabled())
end, { desc = "Toggle inlay hints" })

vim.keymap.set("n", "<Tab>", function()
  if require("sidekick").nes_jump_or_apply() then
    return nil
  end

  return "<C-i>"
end, { desc = "Accept Copilot NES suggestion", expr = true, silent = true })

vim.keymap.set("n", "<leader>lc", function()
  require("sidekick.nes").clear()
end, { desc = "Clear Copilot suggestion" })
