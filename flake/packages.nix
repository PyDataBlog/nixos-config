{ inputs, repoLib, ... }:
{
  perSystem =
    { system, ... }:
    let
      pkgs = repoLib.mkPkgs {
        inherit system;
      };
      pkgsStable = repoLib.mkPkgsStable system;
      repoPackages = import ../packages {
        inherit pkgs pkgsStable;
        lib = pkgs.lib;
        claudeCodePkg = inputs.claude-code-nix.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;
        codexPkg = inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.codex;
      };
      nixvim = import ../wrappers/nixvim.nix {
        inherit inputs pkgs system;
        lib = pkgs.lib;
        inherit pkgsStable;
      };
      cli = import ../wrappers/cli.nix {
        inherit
          inputs
          pkgs
          system
          pkgsStable
          ;
        full = false;
      };
      cliFull = import ../wrappers/cli.nix {
        inherit
          inputs
          pkgs
          system
          pkgsStable
          ;
        full = true;
      };
      tmux = import ../wrappers/tmux.nix {
        inherit
          inputs
          pkgs
          pkgsStable
          ;
      };
      emacs = import ../wrappers/emacs.nix { inherit pkgs; };
      lf = repoPackages.lfWrapped;
      jj = repoPackages.jjWrapped;
      qalc = repoPackages.qalcWrapped;
      emacsApp = {
        type = "app";
        program = "${emacs}/bin/emacs";
        meta.description = "Portable wrapped Emacs with a modern plugin stack from this flake";
      };
      nvimApp = {
        type = "app";
        program = "${nixvim}/bin/nvim";
        meta.description = "Portable standalone Nixvim build from this flake";
      };
      cliApp = {
        type = "app";
        program = "${cli}/bin/portable-cli";
        meta.description = "Portable standalone core CLI environment from this flake";
      };
      cliFullApp = {
        type = "app";
        program = "${cliFull}/bin/portable-cli-full";
        meta.description = "Portable standalone full CLI workbench from this flake";
      };
      tmuxApp = {
        type = "app";
        program = "${tmux}/bin/tmux";
        meta.description = "Portable wrapped tmux using this repo's tmux configuration";
      };
      lfApp = {
        type = "app";
        program = "${lf}/bin/lf";
        meta.description = "Portable wrapped lf file manager from this flake";
      };
      qalcApp = {
        type = "app";
        program = "${qalc}/bin/qalc";
        meta.description = "Portable wrapped libqalculate CLI from this flake";
      };
      jjApp = {
        type = "app";
        program = "${jj}/bin/jj";
        meta.description = "Portable wrapped Jujutsu CLI from this flake";
      };
    in
    {
      packages = {
        inherit
          cli
          cliFull
          emacs
          jj
          lf
          nixvim
          qalc
          tmux
          ;
        "cli-full" = cliFull;
        default = nixvim;
      };

      apps = {
        cli = cliApp;
        cliFull = cliFullApp;
        "cli-full" = cliFullApp;
        emacs = emacsApp;
        jj = jjApp;
        lf = lfApp;
        nixvim = nvimApp;
        qalc = qalcApp;
        tmux = tmuxApp;
        default = nvimApp;
      };
    };
}
