{ claudeCodePkg, codexPkg, lib, pkgs, ... }:
let
  repoPackages = import ../../packages {
    inherit pkgs lib;
    inherit claudeCodePkg codexPkg;
  };
in
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
    ./search.nix
    ./kube.nix
    ./markdown.nix
    ./requests.nix
    ./sql.nix
    ./codecompanion.nix
    ./runtime-files.nix
  ];

  extraPlugins = with pkgs.vimPlugins; [ friendly-snippets ];

  # Keep the wrapped editor usable on a plain Linux machine with only Nix.
  extraPackages = lib.unique (
    repoPackages.languages
    ++ repoPackages.kubernetes
    ++ (with pkgs; [
      ast-grep
      pkgs."bash-language-server"
      bubblewrap
      codexPkg
      claudeCodePkg
      copilot-language-server
      curl
      chafa
      bashunit
      checkmake
      deadnix
      delve
      djlint
      pkgs."docker-compose-language-service"
      pkgs."dockerfile-language-server"
      exiftool
      fd
      ffmpeg
      git
      gitleaks
      gofumpt
      pkgs."golangci-lint"
      golines
      gopls
      gosimports
      grpcurl
      hadolint
      pkgs."helm-ls"
      imagemagick
      jq
      lazygit
      lsof
      pkgs."lua-language-server"
      markdown-toc
      markdownlint-cli2
      marksman
      mediainfo
      nushell
      opencode
      openssl
      pandoc
      pkgs."poppler-utils"
      prettier
      prettierd
      presenterm
      procps
      pkgs.python3Packages.debugpy
      ripgrep
      ruff
      pkgs."rust-analyzer"
      shellcheck
      shfmt
      sqlfluff
      sqls
      statix
      stylua
      taplo
      tectonic
      pkgs."terraform-ls"
      texlab
      tflint
      tmux
      ty
      pkgs."typos-lsp"
      websocat
      pkgs."vscode-langservers-extracted"
      wl-clipboard
      pkgs."yaml-language-server"
      yamllint
      xclip
      xsel
      xdg-utils
      yt-dlp
      zls
    ])
  );
}
