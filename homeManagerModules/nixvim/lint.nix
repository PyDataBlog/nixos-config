{ lib, pkgs, ... }:
{
  extraPlugins = [ pkgs.vimPlugins."nvim-lint" ];

  extraConfigLuaPost = lib.mkAfter ''
    local lint = require('lint')

    lint.linters_by_ft = {
      bash = { 'shellcheck' },
      dockerfile = { 'hadolint' },
      go = { 'golangcilint' },
      htmldjango = { 'djlint' },
      make = { 'checkmake' },
      markdown = { 'markdownlint-cli2' },
      mysql = { 'sqlfluff' },
      nix = { 'deadnix', 'statix' },
      plsql = { 'sqlfluff' },
      python = { 'ruff' },
      sh = { 'shellcheck' },
      sql = { 'sqlfluff' },
      terraform = { 'tflint' },
      ['terraform-vars'] = { 'tflint' },
      yaml = { 'yamllint' },
      ['yaml.docker-compose'] = { 'yamllint' },
      ['yaml.helm-values'] = { 'yamllint' },
      zsh = { 'shellcheck' },
    }

    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      callback = function()
        lint.try_lint()
      end,
      desc = 'Run nvim-lint',
    })
  '';
}
