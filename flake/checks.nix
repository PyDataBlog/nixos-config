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
    in
    {
      checks = {
        cli = self'.packages.cli;
        cli-smoke = pkgs.runCommandLocal "cli-smoke" { } ''
          export HOME="$TMPDIR/home"
          export XDG_CACHE_HOME="$TMPDIR/cache"
          export XDG_CONFIG_HOME="$TMPDIR/config"
          export XDG_DATA_HOME="$TMPDIR/share"
          export XDG_STATE_HOME="$TMPDIR/state"
          export TERM="xterm-256color"
          mkdir -p "$HOME" "$XDG_CACHE_HOME" "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME"

          [ "$(${self'.packages.cli}/bin/portable-cli -c 'print $env.EDITOR')" = "nvim" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'print $env.config.edit_mode')" = "vi" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'print $env.SHELL')" = "${self'.packages.cli}/bin/nu" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'print $env.UV_NO_MANAGED_PYTHON')" = "1" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'print $env.UV_PYTHON_DOWNLOADS')" = "never" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which act | get path.0')" = "${pkgs.act}/bin/act" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which ast-grep | get path.0')" = "${pkgs.ast-grep}/bin/ast-grep" ]
          ${self'.packages.cli}/bin/portable-cli -c 'which az | get path.0' | grep -Eq '/bin/az$'
          ${self'.packages.cli}/bin/portable-cli -c 'which azcopy | get path.0' | grep -Eq '/bin/azcopy$'
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which bwrap | get path.0')" = "${pkgs.bubblewrap}/bin/bwrap" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which cargo-release | get path.0')" = "${pkgs.cargo-release}/bin/cargo-release" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which chafa | get path.0')" = "${pkgs.chafa}/bin/chafa" ]
          ${self'.packages.cli}/bin/portable-cli -c 'which claude | get path.0' | grep -Eq '/bin/claude$'
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which claudecode | get type.0')" = "alias" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which claudecode | get definition.0')" = "claude" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which cmake | get path.0')" = "${pkgs.cmake}/bin/cmake" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which exiftool | get path.0')" = "${pkgs.exiftool}/bin/exiftool" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which ffmpeg | get path.0')" = "${pkgs.ffmpeg}/bin/ffmpeg" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which glow | get path.0')" = "${pkgs.glow}/bin/glow" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which grpcurl | get path.0')" = "${pkgs.grpcurl}/bin/grpcurl" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which magick | get path.0')" = "${pkgs.imagemagick}/bin/magick" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which mediainfo | get path.0')" = "${pkgs.mediainfo}/bin/mediainfo" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which mmdc | get path.0')" = "${pkgs.mermaid-cli}/bin/mmdc" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which oc | get type.0')" = "alias" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which oc | get definition.0')" = "opencode" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which opencode | get path.0')" = "${pkgs.opencode}/bin/opencode" ]
          ${self'.packages.cli}/bin/portable-cli -c 'which openssl | get path.0' | grep -Eq '/bin/openssl$'
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which pandoc | get path.0')" = "${pkgs.pandoc}/bin/pandoc" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which pdfinfo | get path.0')" = "${pkgs."poppler-utils"}/bin/pdfinfo" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which presenterm | get path.0')" = "${pkgs.presenterm}/bin/presenterm" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which python3 | get path.0')" = "${pkgs.python3}/bin/python3" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which rich | get path.0')" = "${pkgs.rich-cli}/bin/rich" ]
          ${self'.packages.cli}/bin/portable-cli -c 'which tectonic | get path.0' | grep -Eq '/bin/tectonic$'
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which texlab | get path.0')" = "${pkgs.texlab}/bin/texlab" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which timg | get path.0')" = "${pkgs.timg}/bin/timg" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which go | get path.0')" = "${pkgs.go}/bin/go" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which cargo | get path.0')" = "${pkgs.cargo}/bin/cargo" ]
          ${self'.packages.cli}/bin/portable-cli -c 'which rustc | get path.0' | grep -Eq '/bin/rustc$'
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which node | get path.0')" = "${pkgs.nodejs}/bin/node" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which sqlite3 | get path.0')" = "${pkgs.lib.getBin pkgs.sqlite}/bin/sqlite3" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which websocat | get path.0')" = "${pkgs.websocat}/bin/websocat" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which yt-dlp | get path.0')" = "${pkgs.yt-dlp}/bin/yt-dlp" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which zig | get path.0')" = "${pkgs.zig}/bin/zig" ]
          ${self'.packages.cli}/bin/portable-cli -c 'which terraform | get path.0' | grep -Eq '/bin/terraform$'
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which kubectl | get path.0')" = "${
            (import ../packages {
              inherit pkgs;
              pkgsStable = self.lib.mkPkgsStable pkgs.stdenv.hostPlatform.system;
              lib = pkgs.lib;
              claudeCodePkg = self.inputs.claude-code-nix.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;
              codexPkg = self.inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.codex;
            }).kubectlWrapped
          }/bin/kubectl" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which kubecolor | get path.0')" = "${pkgs.kubecolor}/bin/kubecolor" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which helm | get path.0')" = "${pkgs.kubernetes-helm}/bin/helm" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which hx | get path.0')" = "${pkgs.helix}/bin/hx" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which kustomize | get path.0')" = "${pkgs.kustomize}/bin/kustomize" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which kubectx | get path.0')" = "${pkgs.kubectx}/bin/kubectx" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which stern | get path.0')" = "${pkgs.stern}/bin/stern" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which k9s | get path.0')" = "${pkgs.k9s}/bin/k9s" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which k3d | get path.0')" = "${pkgs.k3d}/bin/k3d" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which kind | get path.0')" = "${pkgs.kind}/bin/kind" ]
          [ "$(${self'.packages.cli}/bin/portable-cli -c 'which trivy | get path.0')" = "${pkgs.trivy}/bin/trivy" ]
          ${self'.packages.cli}/bin/portable-cli -c '^kubectl version --client --output=yaml | str contains "clientVersion"' | grep -qx true
          grep -Fqx 'alias "cc" = claude' ${self'.packages.cli}/share/config.nu
          grep -Fqx 'alias "claudecode" = claude' ${self'.packages.cli}/share/config.nu
          grep -Fqx 'alias "k" = kubectl' ${self'.packages.cli}/share/config.nu
          grep -Fqx 'alias "oc" = opencode' ${self'.packages.cli}/share/config.nu
          grep -Eq 'base-index[[:space:]]+1$' ${self'.packages.cli}/share/tmux.conf
          grep -Fqx 'set -g default-shell "${self'.packages.cli}/bin/nu"' ${self'.packages.cli}/share/tmux.conf
          mkdir "$TMPDIR/project"
          ${self'.packages.cli}/bin/portable-cli -c 'cd '"$TMPDIR"'/project; uv venv'
          ${self'.packages.cli}/bin/nvim --headless '+lua assert(vim.g.colors_name == "miniwinter"); assert(vim.o.shell == [[${self'.packages.cli}/bin/nu]])' '+qall'

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

          ${self'.packages.nixvim}/bin/nvim --headless '+lua assert(vim.g.colors_name == "miniwinter"); assert(vim.fn.executable("ast-grep") == 1); assert(vim.fn.executable("bashunit") == 1); assert(vim.fn.executable("bwrap") == 1); assert(vim.fn.executable("chafa") == 1); assert(vim.fn.executable("claude") == 1); assert(vim.fn.executable("debugpy-adapter") == 1); assert(vim.fn.executable("djlint") == 1); assert(vim.fn.executable("dlv") == 1); assert(vim.fn.executable("exiftool") == 1); assert(vim.fn.executable("fd") == 1); assert(vim.fn.executable("ffmpeg") == 1); assert(vim.fn.executable("git") == 1); assert(vim.fn.executable("glow") == 1); assert(vim.fn.executable("gopls") == 1); assert(vim.fn.executable("grpcurl") == 1); assert(vim.fn.executable("helm") == 1); assert(vim.fn.executable("jq") == 1); assert(vim.fn.executable("k3d") == 1); assert(vim.fn.executable("k9s") == 1); assert(vim.fn.executable("kubecolor") == 1); assert(vim.fn.executable("kubectl") == 1); assert(vim.fn.executable("kubectx") == 1); assert(vim.fn.executable("kustomize") == 1); assert(vim.fn.executable("lsof") == 1); assert(vim.fn.executable("lldb-dap") == 1); assert(vim.fn.executable("magick") == 1); assert(vim.fn.executable("markdownlint-cli2") == 1); assert(vim.fn.executable("mmdc") == 1); assert(vim.fn.executable("mediainfo") == 1); assert(vim.fn.executable("nu") == 1); assert(vim.fn.executable("opencode") == 1); assert(vim.fn.executable("openssl") == 1); assert(vim.fn.executable("pandoc") == 1); assert(vim.fn.executable("pdfinfo") == 1); assert(vim.fn.executable("presenterm") == 1); assert(vim.fn.executable("ps") == 1); assert(vim.fn.executable("rg") == 1); assert(vim.fn.executable("rich") == 1); assert(vim.fn.executable("ruff") == 1); assert(vim.fn.executable("shellcheck") == 1); assert(vim.fn.executable("sqlite3") == 1); assert(vim.fn.executable("sqlfluff") == 1); assert(vim.fn.executable("stern") == 1); assert(vim.fn.executable("tectonic") == 1); assert(vim.fn.executable("terraform") == 1); assert(vim.fn.executable("texlab") == 1); assert(vim.fn.executable("timg") == 1); assert(vim.fn.executable("trivy") == 1); assert(vim.fn.executable("websocat") == 1); assert(vim.fn.executable("xclip") == 1); assert(vim.fn.executable("xsel") == 1); assert(vim.fn.executable("wl-copy") == 1); assert(vim.fn.executable("xdg-open") == 1); assert(vim.fn.executable("yt-dlp") == 1); assert(pcall(require, "codecompanion")); assert(pcall(require, "dap")); assert(pcall(require, "dap-go")); assert(pcall(require, "dap-python")); assert(pcall(require, "grug-far")); assert(pcall(require, "kubectl")); assert(pcall(require, "kulala")); assert(pcall(require, "lazydev")); assert(pcall(require, "lint")); assert(pcall(require, "neotest")); assert(pcall(require, "render-markdown")); assert(pcall(require, "schemastore")); assert(pcall(require, "sidekick")); assert(vim.fn.exists(":CodeCompanion") == 2); assert(vim.fn.exists(":DapViewToggle") == 2); assert(vim.fn.exists(":DBUIAddConnection") == 2); assert(vim.fn.exists(":DBUIFindBuffer") == 2); assert(vim.fn.exists(":DBUIToggle") == 2); assert(vim.fn.exists(":GrugFar") == 2); assert(vim.fn.exists(":Kubectl") == 2); assert(vim.fn.exists(":MarkdownPreviewToggle") == 2); assert(vim.fn.exists(":RenderMarkdown") == 2); assert(vim.fn.maparg("<leader>fq", "n") ~= ""); assert(vim.fn.maparg("<leader>fQ", "n") ~= ""); assert(vim.fn.maparg("<leader>kk", "n") ~= ""); assert(vim.fn.maparg("<leader>ob", "n") ~= ""); assert(vim.fn.maparg("<leader>od", "n") ~= ""); assert(vim.fn.maparg("<leader>dc", "n") ~= ""); assert(vim.fn.maparg("<leader>ll", "n") ~= ""); assert(vim.fn.maparg("<leader>lM", "n") ~= ""); assert(vim.fn.maparg("<leader>lP", "n") ~= ""); assert(vim.fn.maparg("<leader>nd", "n") ~= ""); assert(vim.fn.maparg("<leader>nn", "n") ~= ""); assert(vim.fn.maparg("<leader>rr", "n") ~= ""); assert(vim.fn.maparg("<leader>ry", "n") ~= ""); assert(vim.fn.exists(":LspCopilotSignIn") == 2); assert(vim.fn.exists(":LspCopilotSignOut") == 2); assert(vim.env.CODECOMPANION_TOKEN_PATH == nil); assert(vim.env.NIXVIM_SHELL == [[${pkgs.nushell}/bin/nu]]); assert(vim.o.shell == [[${pkgs.nushell}/bin/nu]])' '+qall'

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
              execStart = pkgs.lib.concatStringsSep " " service.Service.ExecStart;
            in
            if service.Unit.PartOf == [ "niri.service" ] && service.Unit.Requisite == [ "niri.service" ] then
              execStart
            else
              throw "swayidle is not bound to niri.service"
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
        '';
      };
    };
}
