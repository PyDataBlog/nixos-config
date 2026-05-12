{ self, ... }:
{
  perSystem =
    { pkgs, self', ... }:
    let
      primaryUsername = self.nixosConfigurations.desktop.config.repo.user.username;
      hmUser = self.nixosConfigurations.desktop.config.home-manager.users.${primaryUsername};
      overrideDesktop = self.nixosConfigurations.desktop.extendModules {
        modules = [
          {
            repo.user = self.lib.primaryUser // {
              username = "adopter";
              description = "Adopter";
              homeDirectory = "/home/adopter";
            };
            repo.locale = {
              timeZone = "UTC";
              defaultLocale = "en_US.UTF-8";
              extraLocaleSettings = {
                LC_TIME = "en_GB.UTF-8";
              };
            };
            repo.location = {
              name = "New York, USA";
              latitude = "40.7128";
              longitude = "-74.0060";
            };
            repo.idle = {
              lockSeconds = 300;
              monitorOffSeconds = 360;
            };
            repo.nightLight = {
              dayTemperature = 6000;
              nightTemperature = 3400;
            };
            repo.niri.outputs = [
              {
                name = "HDMI-A-1";
                mode = "1920x1080@60";
                scale = 1;
              }
            ];
          }
        ];
      };
      overrideHmUser = overrideDesktop.config.home-manager.users.adopter;
      cliFullPkg = self'.packages."cli-full";
    in
    {
      checks = {
        cli = self'.packages.cli;
        cliFull = cliFullPkg;
        emacs = self'.packages.emacs;
        tmux = self'.packages.tmux;
        emacs-smoke = pkgs.runCommandLocal "emacs-smoke" { } ''
          export HOME="$TMPDIR/home"
          mkdir -p "$HOME"

          ${self'.packages.emacs}/bin/emacs --batch \
            --load ${self'.packages.emacs}/share/emacs/init.el \
            --eval "(progn (require 'vertico) (require 'orderless) (require 'consult) (require 'embark) (require 'corfu) (require 'which-key) (require 'evil) (require 'general) (require 'helpful) (require 'magit) (require 'vterm) (princ (if (member 'doom-nord custom-enabled-themes) \"ok\" \"theme-missing\")))" \
            | grep -qx ok

          [ -x ${self'.packages.emacs}/bin/emacsclient ]

          touch "$out"
        '';
        lf = self'.packages.lf;
        lf-smoke = pkgs.runCommandLocal "lf-smoke" { } ''
          ${self'.packages.lf}/bin/lf -help >/dev/null
          touch "$out"
        '';
        tmux-smoke = pkgs.runCommandLocal "tmux-smoke" { } ''
          TERM=xterm-256color ${self'.packages.tmux}/bin/tmux -V | grep -Eq '^tmux '
          [ -x ${self'.packages.tmux}/bin/nu ]
          [ "$(${self'.packages.tmux}/bin/nu -c 'print $env.EDITOR')" = "nvim" ]
          [ "$(${self'.packages.tmux}/bin/nu -c 'which nvim | get path.0')" = "${pkgs.neovim}/bin/nvim" ]
          grep -Fqx 'set -g default-shell "${self'.packages.tmux}/bin/nu"' ${self'.packages.tmux}/share/tmux.conf
          grep -Fqx 'set -g allow-passthrough on' ${self'.packages.tmux}/share/tmux.conf
          grep -Fq 'ghostty:RGB,clipboard' ${self'.packages.tmux}/share/tmux.conf
          grep -Fq 'tmux-256color:RGB,clipboard' ${self'.packages.tmux}/share/tmux.conf
          grep -Fq 'bind-key r run-shell' ${self'.packages.tmux}/share/tmux.conf
          grep -Fqx 'bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel' ${self'.packages.tmux}/share/tmux.conf
          grep -Fqx 'bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-selection-and-cancel' ${self'.packages.tmux}/share/tmux.conf
          touch "$out"
        '';
        jj = self'.packages.jj;
        jj-smoke = pkgs.runCommandLocal "jj-smoke" { } ''
          ${self'.packages.jj}/bin/jj --version | grep -Eq '^jj '
          touch "$out"
        '';
        qalc = self'.packages.qalc;
        qalc-smoke = pkgs.runCommandLocal "qalc-smoke" { } ''
          [ "$(${self'.packages.qalc}/bin/qalc -t '1+1')" = "2" ]
          touch "$out"
        '';
        cli-smoke = pkgs.runCommandLocal "cli-smoke" { } ''
          export HOME="$TMPDIR/home"
          export XDG_CACHE_HOME="$TMPDIR/cache"
          export XDG_CONFIG_HOME="$TMPDIR/config"
          export XDG_DATA_HOME="$TMPDIR/share"
          export XDG_STATE_HOME="$TMPDIR/state"
          export TERM="xterm-256color"
          mkdir -p "$HOME" "$XDG_CACHE_HOME" "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME"

          cat > "$TMPDIR/k3d-completion.nu" <<'EOF'
          let cluster = ((nu-complete k3d "k3d c") | get 0.value)
          if $cluster != "cluster" {
            error make { msg: $"unexpected k3d completion: ($cluster)" }
          }

          let create = ((nu-complete k3d "k3d cluster c") | get 0.value)
          if $create != "create" {
            error make { msg: $"unexpected k3d subcommand completion: ($create)" }
          }
          EOF

          [ "$(${self'.packages.cli}/bin/portable-cli -c 'print $env.EDITOR')" = "nvim" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'print $env.config.edit_mode')" = "vi" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'print $env.SHELL')" = "${self'.packages.cli}/bin/nu" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'print $env.UV_NO_MANAGED_PYTHON')" = "1" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'print $env.UV_PYTHON_DOWNLOADS')" = "never" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which ast-grep | get path.0')" = "${pkgs.ast-grep}/bin/ast-grep" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which bwrap | get path.0')" = "${pkgs.bubblewrap}/bin/bwrap" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which cargo-release | get path.0')" = "${pkgs.cargo-release}/bin/cargo-release" ]
          ${self'.packages.cli}/bin/portable-cli -c 'which claude | get path.0' | grep -Eq '/bin/claude$'
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which claudecode | get type.0')" = "alias" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which claudecode | get definition.0')" = "claude" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which cmake | get path.0')" = "${pkgs.cmake}/bin/cmake" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which grpcurl | get path.0')" = "${pkgs.grpcurl}/bin/grpcurl" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which jj | get path.0')" = "${self'.packages.jj}/bin/jj" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which oc | get type.0')" = "alias" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which oc | get definition.0')" = "opencode" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which opencode | get path.0')" = "${pkgs.opencode}/bin/opencode" ]
          ${self'.packages.cli}/bin/portable-cli -c 'which openssl | get path.0' | grep -Eq '/bin/openssl$'
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which python3 | get path.0')" = "${pkgs.python3}/bin/python3" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which qalc | get path.0')" = "${self'.packages.qalc}/bin/qalc" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which kubectl | get path.0')" = "${
            (import ../packages {
              inherit pkgs;
              pkgsStable = self.lib.mkPkgsStable pkgs.stdenv.hostPlatform.system;
              lib = pkgs.lib;
              claudeCodePkg = self.inputs.claude-code-nix.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;
              codexPkg = self.inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.codex;
            }).kubectlWrapped
          }/bin/kubectl" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which websocat | get path.0')" = "${pkgs.websocat}/bin/websocat" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which hx | get path.0')" = "${pkgs.helix}/bin/hx" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which k3d | get type.0')" = "custom" ]
          ${self'.packages.cli}/bin/portable-cli "$TMPDIR/k3d-completion.nu"
          ${self'.packages.cli}/bin/portable-cli -c '^kubectl version --client --output=yaml | str contains "clientVersion"' | grep -qx true
          grep -Fq 'def --wrapped k3d [...rest: string@"nu-complete k3d"]' ${self'.packages.cli}/share/config.nu
          grep -Fqx 'alias "cc" = claude' ${self'.packages.cli}/share/config.nu
          grep -Fqx 'alias "claudecode" = claude' ${self'.packages.cli}/share/config.nu
          grep -Fqx 'alias "k" = kubectl' ${self'.packages.cli}/share/config.nu
          grep -Fqx 'alias "oc" = opencode' ${self'.packages.cli}/share/config.nu
          grep -Eq 'base-index[[:space:]]+1$' ${self'.packages.cli}/share/tmux.conf
          grep -Fqx 'set -g default-shell "${self'.packages.cli}/bin/nu"' ${self'.packages.cli}/share/tmux.conf
          mkdir "$TMPDIR/project"
          ${self'.packages.cli}/bin/portable-cli -c 'cd '"$TMPDIR"'/project; uv venv'
          ${self'.packages.cli}/bin/nvim --headless '+lua assert(vim.o.shell == [[${self'.packages.cli}/bin/nu]])' '+qall'

          touch "$out"
        '';
        cli-full-smoke = pkgs.runCommandLocal "cli-full-smoke" { } ''
          export HOME="$TMPDIR/home"
          export XDG_CACHE_HOME="$TMPDIR/cache"
          export XDG_CONFIG_HOME="$TMPDIR/config"
          export XDG_DATA_HOME="$TMPDIR/share"
          export XDG_STATE_HOME="$TMPDIR/state"
          export TERM="xterm-256color"
          mkdir -p "$HOME" "$XDG_CACHE_HOME" "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME"

          cat > "$TMPDIR/k3d-completion.nu" <<'EOF'
          let cluster = ((nu-complete k3d "k3d c") | get 0.value)
          if $cluster != "cluster" {
            error make { msg: $"unexpected k3d completion: ($cluster)" }
          }

          let create = ((nu-complete k3d "k3d cluster c") | get 0.value)
          if $create != "create" {
            error make { msg: $"unexpected k3d subcommand completion: ($create)" }
          }
          EOF

          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'print $env.EDITOR')" = "nvim" ]
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'print $env.config.edit_mode')" = "vi" ]
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'print $env.SHELL')" = "${cliFullPkg}/bin/nu" ]
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'print $env.UV_NO_MANAGED_PYTHON')" = "1" ]
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'print $env.UV_PYTHON_DOWNLOADS')" = "never" ]
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which act | get path.0')" = "${pkgs.act}/bin/act" ]
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which ast-grep | get path.0')" = "${pkgs.ast-grep}/bin/ast-grep" ]
          ${cliFullPkg}/bin/portable-cli-full -c 'which az | get path.0' | grep -Eq '/bin/az$'
          ${cliFullPkg}/bin/portable-cli-full -c 'which azcopy | get path.0' | grep -Eq '/bin/azcopy$'
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which bwrap | get path.0')" = "${pkgs.bubblewrap}/bin/bwrap" ]
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which cargo-release | get path.0')" = "${pkgs.cargo-release}/bin/cargo-release" ]
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which chafa | get path.0')" = "${pkgs.chafa}/bin/chafa" ]
          ${cliFullPkg}/bin/portable-cli-full -c 'which claude | get path.0' | grep -Eq '/bin/claude$'
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which claudecode | get type.0')" = "alias" ]
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which claudecode | get definition.0')" = "claude" ]
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which cmake | get path.0')" = "${pkgs.cmake}/bin/cmake" ]
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which exiftool | get path.0')" = "${pkgs.exiftool}/bin/exiftool" ]
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which ffmpeg | get path.0')" = "${pkgs.ffmpeg}/bin/ffmpeg" ]
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which glow | get path.0')" = "${pkgs.glow}/bin/glow" ]
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which grpcurl | get path.0')" = "${pkgs.grpcurl}/bin/grpcurl" ]
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which lf | get path.0')" = "${self'.packages.lf}/bin/lf" ]
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which magick | get path.0')" = "${pkgs.imagemagick}/bin/magick" ]
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which mediainfo | get path.0')" = "${pkgs.mediainfo}/bin/mediainfo" ]
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which mmdc | get path.0')" = "${pkgs.mermaid-cli}/bin/mmdc" ]
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which jj | get path.0')" = "${self'.packages.jj}/bin/jj" ]
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which oc | get type.0')" = "alias" ]
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which oc | get definition.0')" = "opencode" ]
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which opencode | get path.0')" = "${pkgs.opencode}/bin/opencode" ]
          ${cliFullPkg}/bin/portable-cli-full -c 'which openssl | get path.0' | grep -Eq '/bin/openssl$'
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which obsidian-export | get path.0')" = "${pkgs.obsidian-export}/bin/obsidian-export" ]
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which pandoc | get path.0')" = "${pkgs.pandoc}/bin/pandoc" ]
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which pdfinfo | get path.0')" = "${pkgs."poppler-utils"}/bin/pdfinfo" ]
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which presenterm | get path.0')" = "${pkgs.presenterm}/bin/presenterm" ]
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which python3 | get path.0')" = "${pkgs.python3}/bin/python3" ]
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which qalc | get path.0')" = "${self'.packages.qalc}/bin/qalc" ]
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which rich | get path.0')" = "${pkgs.rich-cli}/bin/rich" ]
          ${cliFullPkg}/bin/portable-cli-full -c 'which tectonic | get path.0' | grep -Eq '/bin/tectonic$'
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which texlab | get path.0')" = "${pkgs.texlab}/bin/texlab" ]
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which timg | get path.0')" = "${pkgs.timg}/bin/timg" ]
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which go | get path.0')" = "${pkgs.go}/bin/go" ]
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which cargo | get path.0')" = "${pkgs.cargo}/bin/cargo" ]
          ${cliFullPkg}/bin/portable-cli-full -c 'which rustc | get path.0' | grep -Eq '/bin/rustc$'
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which node | get path.0')" = "${pkgs.nodejs}/bin/node" ]
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which sqlite3 | get path.0')" = "${pkgs.lib.getBin pkgs.sqlite}/bin/sqlite3" ]
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which websocat | get path.0')" = "${pkgs.websocat}/bin/websocat" ]
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which yt-dlp | get path.0')" = "${pkgs.yt-dlp}/bin/yt-dlp" ]
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which zig | get path.0')" = "${pkgs.zig}/bin/zig" ]
          ${cliFullPkg}/bin/portable-cli-full -c 'which terraform | get path.0' | grep -Eq '/bin/terraform$'
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which kubectl | get path.0')" = "${
            (import ../packages {
              inherit pkgs;
              pkgsStable = self.lib.mkPkgsStable pkgs.stdenv.hostPlatform.system;
              lib = pkgs.lib;
              claudeCodePkg = self.inputs.claude-code-nix.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;
              codexPkg = self.inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.codex;
            }).kubectlWrapped
          }/bin/kubectl" ]
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which kubecolor | get path.0')" = "${pkgs.kubecolor}/bin/kubecolor" ]
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which helm | get path.0')" = "${pkgs.kubernetes-helm}/bin/helm" ]
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which hx | get path.0')" = "${pkgs.helix}/bin/hx" ]
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which kustomize | get path.0')" = "${pkgs.kustomize}/bin/kustomize" ]
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which kubectx | get path.0')" = "${pkgs.kubectx}/bin/kubectx" ]
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which stern | get path.0')" = "${pkgs.stern}/bin/stern" ]
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which k9s | get path.0')" = "${pkgs.k9s}/bin/k9s" ]
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which k3d | get type.0')" = "custom" ]
          ${cliFullPkg}/bin/portable-cli-full "$TMPDIR/k3d-completion.nu"
          ${self'.packages.lf}/bin/lf -help >/dev/null
          grep -Fq -- '-config ' ${self'.packages.lf}/bin/lf
          grep -Fq 'def --wrapped k3d [...rest: string@"nu-complete k3d"]' ${cliFullPkg}/share/config.nu
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which kind | get path.0')" = "${pkgs.kind}/bin/kind" ]
          [ "$(${cliFullPkg}/bin/portable-cli-full -c 'which trivy | get path.0')" = "${pkgs.trivy}/bin/trivy" ]
          ${cliFullPkg}/bin/portable-cli-full -c '^kubectl version --client --output=yaml | str contains "clientVersion"' | grep -qx true
          grep -Fqx 'alias "cc" = claude' ${cliFullPkg}/share/config.nu
          grep -Fqx 'alias "claudecode" = claude' ${cliFullPkg}/share/config.nu
          grep -Fqx 'alias "k" = kubectl' ${cliFullPkg}/share/config.nu
          grep -Fqx 'alias "oc" = opencode' ${cliFullPkg}/share/config.nu
          grep -Eq 'base-index[[:space:]]+1$' ${cliFullPkg}/share/tmux.conf
          grep -Fqx 'set -g default-shell "${cliFullPkg}/bin/nu"' ${cliFullPkg}/share/tmux.conf
          mkdir "$TMPDIR/project"
          ${cliFullPkg}/bin/portable-cli-full -c 'cd '"$TMPDIR"'/project; uv venv'
          ${cliFullPkg}/bin/nvim --headless '+lua assert(vim.g.colors_name == "miniwinter"); assert(vim.o.shell == [[${cliFullPkg}/bin/nu]])' '+qall'

          touch "$out"
        '';
        nixvim = self'.packages.nixvim;
        nixvim-smoke = pkgs.runCommandLocal "nixvim-smoke" { } ''
          export HOME="$TMPDIR/home"
          export XDG_CACHE_HOME="$TMPDIR/cache"
          export XDG_CONFIG_HOME="$TMPDIR/config"
          export XDG_DATA_HOME="$TMPDIR/share"
          export XDG_STATE_HOME="$TMPDIR/state"
          mkdir -p "$HOME" "$XDG_CACHE_HOME" "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME"

          STARTUP_LOG="$TMPDIR/nvim-startup.log"
          ${self'.packages.nixvim}/bin/nvim --headless -V1"$STARTUP_LOG" +qall >/dev/null 2>&1
          ! grep -Eq 'E216|E716|Error in |watcher matching|Couldn.t find a watcher' "$STARTUP_LOG"

          ${self'.packages.nixvim}/bin/nvim --headless '+lua local starter=require("mini.starter"); local mini_ai=require("mini.ai"); assert(vim.g.colors_name == "miniwinter"); assert(vim.fn.executable("ast-grep") == 1); assert(vim.fn.executable("bashunit") == 1); assert(vim.fn.executable("bwrap") == 1); assert(vim.fn.executable("chafa") == 1); assert(vim.fn.executable("claude") == 1); assert(vim.fn.executable("debugpy-adapter") == 1); assert(vim.fn.executable("djlint") == 1); assert(vim.fn.executable("dlv") == 1); assert(vim.fn.executable("exiftool") == 1); assert(vim.fn.executable("fd") == 1); assert(vim.fn.executable("ffmpeg") == 1); assert(vim.fn.executable("git") == 1); assert(vim.fn.executable("glow") == 1); assert(vim.fn.executable("gopls") == 1); assert(vim.fn.executable("grpcurl") == 1); assert(vim.fn.executable("helm") == 1); assert(vim.fn.executable("jq") == 1); assert(vim.fn.executable("k3d") == 1); assert(vim.fn.executable("k9s") == 1); assert(vim.fn.executable("kubecolor") == 1); assert(vim.fn.executable("kubectl") == 1); assert(vim.fn.executable("kubectx") == 1); assert(vim.fn.executable("kustomize") == 1); assert(vim.fn.executable("latex2text") == 1); assert(vim.fn.executable("lsof") == 1); assert(vim.fn.executable("lldb-dap") == 1); assert(vim.fn.executable("magick") == 1); assert(vim.fn.executable("markdownlint-cli2") == 1); assert(vim.fn.executable("mmdc") == 1); assert(vim.fn.executable("mediainfo") == 1); assert(vim.fn.executable("nixd") == 1); assert(vim.fn.executable("nixfmt") == 1); assert(vim.fn.executable("nu") == 1); assert(vim.fn.executable("opencode") == 1); assert(vim.fn.executable("openssl") == 1); assert(vim.fn.executable("pandoc") == 1); assert(vim.fn.executable("pdfinfo") == 1); assert(vim.fn.executable("presenterm") == 1); assert(vim.fn.executable("ps") == 1); assert(vim.fn.executable("rg") == 1); assert(vim.fn.executable("rich") == 1); assert(vim.fn.executable("ruff") == 1); assert(vim.fn.executable("shellcheck") == 1); assert(vim.fn.executable("sqlite3") == 1); assert(vim.fn.executable("sqlfluff") == 1); assert(vim.fn.executable("stern") == 1); assert(vim.fn.executable("tectonic") == 1); assert(vim.fn.executable("terraform") == 1); assert(vim.fn.executable("texlab") == 1); assert(vim.fn.executable("timg") == 1); assert(vim.fn.executable("trivy") == 1); assert(vim.fn.executable("websocat") == 1); assert(vim.fn.executable("xclip") == 1); assert(vim.fn.executable("xsel") == 1); assert(vim.fn.executable("wl-copy") == 1); assert(vim.fn.executable("xdg-open") == 1); assert(vim.fn.executable("yt-dlp") == 1); assert(pcall(require, "codecompanion")); assert(pcall(require, "dap")); assert(pcall(require, "dap-go")); assert(pcall(require, "dap-python")); assert(pcall(require, "grug-far")); assert(pcall(require, "kubectl")); assert(pcall(require, "kulala")); assert(pcall(require, "lazydev")); assert(pcall(require, "lint")); assert(pcall(require, "neotest")); assert(pcall(require, "obsidian")); assert(pcall(require, "render-markdown")); assert(pcall(require, "schemastore")); assert(pcall(require, "sidekick")); assert(type(mini_ai.config.custom_textobjects.A) == "function"); assert(type(mini_ai.config.custom_textobjects.C) == "function"); assert(type(mini_ai.config.custom_textobjects.I) == "function"); assert(type(mini_ai.config.custom_textobjects.L) == "function"); assert(type(mini_ai.config.custom_textobjects.P) == "function"); assert(starter.config.autoopen == true); assert(starter.config.evaluate_single == true); assert(type(starter.config.items) == "table"); assert(type(starter.config.header) == "string"); assert(vim.fn.exists(":CodeCompanion") == 2); assert(vim.fn.exists(":DapViewToggle") == 2); assert(vim.fn.exists(":DBUIAddConnection") == 2); assert(vim.fn.exists(":DBUIFindBuffer") == 2); assert(vim.fn.exists(":DBUIToggle") == 2); assert(vim.fn.exists(":GrugFar") == 2); assert(vim.fn.exists(":Kubectl") == 2); assert(vim.fn.exists(":MarkdownPreviewToggle") == 2); assert(vim.fn.exists(":Obsidian") == 0); assert(vim.fn.exists(":RenderMarkdown") == 2); assert(vim.fn.maparg("<leader>fq", "n") ~= ""); assert(vim.fn.maparg("<leader>fQ", "n") ~= ""); assert(vim.fn.maparg("<leader>kk", "n") ~= ""); assert(vim.fn.maparg("<leader>ob", "n") == ""); assert(vim.fn.maparg("<leader>od", "n") == ""); assert(vim.fn.maparg("<leader>on", "n") == ""); assert(vim.fn.maparg("<leader>oo", "n") == ""); assert(vim.fn.maparg("<leader>dc", "n") ~= ""); assert(vim.fn.maparg("<leader>ll", "n") ~= ""); assert(vim.fn.maparg("<leader>lM", "n") ~= ""); assert(vim.fn.maparg("<leader>lP", "n") ~= ""); assert(vim.fn.maparg("<leader>nd", "n") ~= ""); assert(vim.fn.maparg("<leader>nn", "n") ~= ""); assert(vim.fn.maparg("<leader>rr", "n") ~= ""); assert(vim.fn.maparg("<leader>ry", "n") ~= ""); assert(vim.fn.exists(":LspCopilotSignIn") == 2); assert(vim.fn.exists(":LspCopilotSignOut") == 2); assert(vim.env.CODECOMPANION_TOKEN_PATH == nil); assert(vim.env.NIXVIM_SHELL == [[${pkgs.nushell}/bin/nu]]); assert(vim.o.shell == [[${pkgs.nushell}/bin/nu]])' '+qall'
          [ ! -d "$HOME/Notes" ]

          touch "$out"
        '';
        nixvim-language-smoke = pkgs.runCommandLocal "nixvim-language-smoke" { } ''
                    export HOME="$TMPDIR/home"
                    export XDG_CACHE_HOME="$TMPDIR/cache"
                    export XDG_CONFIG_HOME="$TMPDIR/config"
                    export XDG_DATA_HOME="$TMPDIR/share"
                    export XDG_STATE_HOME="$TMPDIR/state"
                    export TERM="xterm-256color"
                    mkdir -p "$HOME" "$XDG_CACHE_HOME" "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME"

                    workspace="$TMPDIR/workspace"
                    mkdir -p "$workspace/templates"
                    export GO_FILE="$workspace/main.go"
                    export TF_FILE="$workspace/main.tf"
                    export MD_FILE="$workspace/README.md"
                    export DJANGO_FILE="$workspace/templates/index.html"
                    export TEX_FILE="$workspace/main.tex"
                    export XML_FILE="$workspace/pom.xml"
                    export OBSIDIAN_FILE="$HOME/Notes/Smoke.md"

                    cat > "$workspace/go.mod" <<'EOF'
          module smoke

          go 1.24
          EOF

                    cat > "$GO_FILE" <<'EOF'
          package main

          import "fmt"

          func main() {
            fmt.Println("smoke")
          }
          EOF

                    cat > "$TF_FILE" <<'EOF'
          terraform {
            required_version = ">= 1.0.0"
          }
          EOF

                    cat > "$MD_FILE" <<'EOF'
          <!-- toc -->

          # Smoke
          EOF

                    cat > "$DJANGO_FILE" <<'EOF'
          {% if user %}
            <h1>Hello {{ user.username }}</h1>
          {% endif %}
          EOF

                    cat > "$TEX_FILE" <<'EOF'
          \documentclass{article}
          \begin{document}
          Smoke
          \end{document}
          EOF

                    cat > "$XML_FILE" <<'EOF'
          <project><name>smoke</name></project>
          EOF

                    mkdir -p "$HOME/Notes"
                    mkdir -p "$HOME/Notes/daily" "$HOME/Notes/templates" "$HOME/Notes/attachments"
                    export OBSIDIAN_ENABLE=1
                    export OBSIDIAN_VAULTS_JSON='[{"name":"personal","path":"'"$HOME"'/Notes","strict":false}]'
                    export OBSIDIAN_DAILY_NOTES_ENABLED=1
                    export OBSIDIAN_DAILY_NOTES_FOLDER='daily'
                    export OBSIDIAN_DAILY_NOTES_WORKDAYS_ONLY=1
                    export OBSIDIAN_DAILY_NOTES_TAGS_JSON='["daily-notes"]'
                    export OBSIDIAN_TEMPLATES_ENABLED=1
                    export OBSIDIAN_TEMPLATES_FOLDER='templates'
                    export OBSIDIAN_ATTACHMENTS_FOLDER='attachments'
                    cat > "$OBSIDIAN_FILE" <<'EOF'
          # Smoke Note

          [[Another Note]]
          EOF

                    cat > "$TMPDIR/nixvim-language-smoke.lua" <<'EOF'
          local conform = require('conform')
          local dap = require('dap')
          local lint = require('lint')

          local function edit(path)
            vim.cmd('edit ' .. vim.fn.fnameescape(path))
          end

          local function has_formatter(name)
            local formatters = conform.list_formatters_to_run(0)
            for _, formatter in ipairs(formatters) do
              if formatter.name == name then
                return true
              end
            end
            return false
          end

          local function assert_lsp_attached(name)
            local ok = vim.wait(5000, function()
              return #vim.lsp.get_clients({ bufnr = 0, name = name }) > 0
            end, 100)
            assert(ok, name .. ' did not attach')
          end

          local function assert_contains(list, value)
            assert(type(list) == 'table', 'expected table containing ' .. value)
            for _, item in ipairs(list) do
              if item == value then
                return
              end
            end
            error('missing ' .. value)
          end

            edit(assert(os.getenv('GO_FILE')))
            assert_lsp_attached('gopls')
            assert(has_formatter('gosimports'))
            assert(has_formatter('gofumpt'))
            assert(has_formatter('golines'))
            assert_contains(lint.linters_by_ft.go, 'golangcilint')

            edit(assert(os.getenv('TF_FILE')))
            assert(has_formatter('terraform_fmt'))
            assert_contains(lint.linters_by_ft.terraform, 'tflint')

            edit(assert(os.getenv('MD_FILE')))
            assert(has_formatter('prettierd'))
            assert(has_formatter('markdown-toc'))
            assert_contains(lint.linters_by_ft.markdown, 'markdownlint-cli2')

            edit(assert(os.getenv('DJANGO_FILE')))
            vim.bo.filetype = 'htmldjango'
            assert(has_formatter('djlint'))
            assert_contains(lint.linters_by_ft.htmldjango, 'djlint')

            edit(assert(os.getenv('TEX_FILE')))
            assert_lsp_attached('texlab')

            edit(assert(os.getenv('XML_FILE')))
            assert(has_formatter('xmllint'))

            edit(assert(os.getenv('OBSIDIAN_FILE')))
            local obsidian_ok = vim.wait(5000, function()
              return vim.b.obsidian_buffer == true
            end, 100)
            assert(obsidian_ok, 'obsidian.nvim did not attach')
            assert(vim.fn.exists(':Obsidian') == 2)
            assert(vim.fn.maparg('<leader>on', 'n') ~= "")
            assert(vim.fn.maparg('<leader>oo', 'n') ~= "")

            assert(dap.configurations.rust[1].cwd == "''${workspaceFolder}")
            assert(dap.configurations.python[#dap.configurations.python].program == "''${workspaceFolder}/manage.py")
          EOF

                    ${self'.packages.nixvim}/bin/nvim --headless \
                      "+lua dofile('${"$"}TMPDIR/nixvim-language-smoke.lua')" \
                      "+qall"

                    touch "$out"
        '';
        host-override-smoke = pkgs.writeText "host-override-smoke" ''
          user=${
            if overrideDesktop.config.repo.user.username == "adopter" then
              "adopter"
            else
              throw "repo.user override did not apply"
          }
          home=${
            if overrideHmUser.home.homeDirectory == "/home/adopter" then
              overrideHmUser.home.homeDirectory
            else
              throw "home-manager user override did not apply"
          }
          timezone=${
            if overrideDesktop.config.time.timeZone == "UTC" then
              overrideDesktop.config.time.timeZone
            else
              throw "timezone override did not apply"
          }
          locale=${
            if overrideDesktop.config.i18n.defaultLocale == "en_US.UTF-8" then
              overrideDesktop.config.i18n.defaultLocale
            else
              throw "locale override did not apply"
          }
          location=${
            if overrideHmUser.programs.noctalia-shell.settings.location.name == "New York, USA" then
              overrideDesktop.config.repo.location.name
            else
              throw "location override did not reach Home Manager"
          }
          idle=${
            if
              overrideDesktop.config.repo.idle.lockSeconds == 300
              && overrideDesktop.config.repo.idle.monitorOffSeconds == 360
            then
              "300/360"
            else
              throw "idle override did not apply"
          }
          nightLight=${
            if
              overrideDesktop.config.repo.nightLight.dayTemperature == 6000
              && overrideDesktop.config.repo.nightLight.nightTemperature == 3400
            then
              "6000/3400"
            else
              throw "night light override did not apply"
          }
          output=${
            if
              (builtins.elemAt overrideDesktop.config.repo.niri.outputs 0).name == "HDMI-A-1"
              && (builtins.elemAt overrideDesktop.config.repo.niri.outputs 0).mode == "1920x1080@60"
            then
              "HDMI-A-1"
            else
              throw "niri output override did not apply"
          }
        '';
        obsidian-disabled-smoke = pkgs.runCommandLocal "obsidian-disabled-smoke" { } ''
          names='${
            builtins.toJSON (
              builtins.map (pkg: pkg.name)
                (self.nixosConfigurations.desktop.extendModules {
                  modules = [ { repo.obsidian.enable = false; } ];
                }).config.environment.systemPackages
            )
          }'
          if printf '%s' "$names" | grep -Eq '"obsidian-[^"]+"'; then
            echo "obsidian is still installed when repo.obsidian.enable = false" >&2
            exit 1
          fi
          touch "$out"
        '';
        noctalia-launcher-smoke = pkgs.runCommandLocal "noctalia-launcher-smoke" { } ''
          config_file=${self.nixosConfigurations.desktop.config.environment.etc."niri/config.kdl".source}
          grep -Fq 'spawn-at-startup "/nix/store/' "$config_file"
          grep -Fq 'start-noctalia' "$config_file"
          grep -Fq 'Mod+Space hotkey-overlay-title="Toggle Noctalia Launcher" { spawn "/nix/store/' "$config_file"
          grep -Fq 'noctalia-ipc' "$config_file"
          grep -Fq '"launcher" "toggle"' "$config_file"
          grep -Fq 'XF86MonBrightnessUp allow-when-locked=true { spawn "/nix/store/' "$config_file"
          grep -Fq '"brightness" "increase"' "$config_file"
          touch "$out"
        '';
        niri-config = self.nixosConfigurations.desktop.config.environment.etc."niri/config.kdl".source;
        session-stack = pkgs.writeText "session-stack-check" ''
          greetd=${
            let
              rawCommand =
                self.nixosConfigurations.desktop.config.services.greetd.settings.default_session.command;
              greetdCommand =
                if builtins.isList rawCommand then
                  pkgs.lib.concatStringsSep " " rawCommand
                else
                  builtins.toString rawCommand;
            in
            if
              self.nixosConfigurations.desktop.config.services.greetd.enable
              && self.nixosConfigurations.desktop.config.programs.regreet.enable
              && builtins.match ".*regreet.*" greetdCommand != null
            then
              greetdCommand
            else
              throw "greetd is not configured to launch regreet"
          }
          swayidle=${
            let
              service = hmUser.systemd.user.services.swayidle;
              execStart = builtins.head service.Service.ExecStart;
            in
            if
              service.Unit.PartOf == [ "niri.service" ]
              && service.Unit.Requisite == [ "niri.service" ]
              && builtins.match ".*niri-idle-session.*" execStart != null
              && builtins.match ".*noctalia-ipc.*lockScreen lock.*" (builtins.readFile execStart) != null
            then
              execStart
            else
              throw "swayidle is not bound to niri.service or does not use the Noctalia recovery wrapper"
          }
          wlsunset=${
            let
              service = hmUser.systemd.user.services.wlsunset;
              execStart = pkgs.lib.concatStringsSep " " service.Service.ExecStart;
            in
            if service.Unit.PartOf == [ "niri.service" ] && service.Unit.Requisite == [ "niri.service" ] then
              execStart
            else
              throw "wlsunset is not bound to niri.service"
          }
          cliphist=${
            let
              service = hmUser.systemd.user.services.cliphist-store;
            in
            if service.Unit.PartOf == [ "niri.service" ] && service.Unit.Requisite == [ "niri.service" ] then
              builtins.toString service.Service.ExecStart
            else
              throw "cliphist-store is not bound to niri.service"
          }
          cliphist_primary=${
            let
              service = hmUser.systemd.user.services.cliphist-store-primary;
            in
            if service.Unit.PartOf == [ "niri.service" ] && service.Unit.Requisite == [ "niri.service" ] then
              builtins.toString service.Service.ExecStart
            else
              throw "cliphist-store-primary is not bound to niri.service"
          }
        '';
      };
    };
}
