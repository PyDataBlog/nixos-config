{ lib, pkgs, ... }:
{
  imports = [
    ./options.nix
    ./keymaps.nix
    ./mini.nix
    ./lsp.nix
    ./dap.nix
    ./lint.nix
    ./neotest.nix
    ./overseer.nix
    ./terminal-tools.nix
    ./treesitter.nix
    ./codecompanion.nix
    ./runtime-files.nix
  ];

  extraPlugins = with pkgs.vimPlugins; [ friendly-snippets ];

  # Keep the wrapped editor usable on a plain Linux machine with only Nix.
  extraPackages = lib.unique (
    with pkgs;
    [
      pkgs."bash-language-server"
      codex
      copilot-language-server
      curl
      bashunit
      checkmake
      deadnix
      delve
      djlint
      pkgs."docker-compose-language-service"
      pkgs."dockerfile-language-server"
      fd
      git
      gitleaks
      gofumpt
      pkgs."golangci-lint"
      golines
      gopls
      gosimports
      hadolint
      pkgs."helm-ls"
      lazygit
      lsof
      pkgs."lua-language-server"
      markdown-toc
      markdownlint-cli2
      marksman
      nushell
      prettier
      prettierd
      presenterm
      procps
      pkgs.python3Packages.debugpy
      ripgrep
      ruff
      pkgs."rust-analyzer"
      rustfmt
      shellcheck
      shfmt
      sqlfluff
      sqls
      statix
      stylua
      taplo
      terraform
      pkgs."terraform-ls"
      tflint
      tmux
      ty
      pkgs."typos-lsp"
      pkgs."vscode-langservers-extracted"
      wl-clipboard
      pkgs."yaml-language-server"
      yamllint
      xclip
      xsel
      zls
      zig
    ]
  );
}
