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
          grep -Eq 'base-index[[:space:]]+1$' ${self'.packages.cli}/share/tmux.conf
          grep -Fqx 'set -g default-shell "${self'.packages.cli}/bin/nu"' ${self'.packages.cli}/share/tmux.conf
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

          ${self'.packages.nixvim}/bin/nvim --headless '+lua assert(vim.g.colors_name == "miniwinter"); assert(vim.fn.executable("bashunit") == 1); assert(vim.fn.executable("debugpy-adapter") == 1); assert(vim.fn.executable("djlint") == 1); assert(vim.fn.executable("dlv") == 1); assert(vim.fn.executable("fd") == 1); assert(vim.fn.executable("git") == 1); assert(vim.fn.executable("gopls") == 1); assert(vim.fn.executable("lsof") == 1); assert(vim.fn.executable("lldb-dap") == 1); assert(vim.fn.executable("markdownlint-cli2") == 1); assert(vim.fn.executable("nu") == 1); assert(vim.fn.executable("ps") == 1); assert(vim.fn.executable("rg") == 1); assert(vim.fn.executable("ruff") == 1); assert(vim.fn.executable("shellcheck") == 1); assert(vim.fn.executable("sqlfluff") == 1); assert(vim.fn.executable("terraform") == 1); assert(vim.fn.executable("xclip") == 1); assert(vim.fn.executable("xsel") == 1); assert(vim.fn.executable("wl-copy") == 1); assert(pcall(require, "codecompanion")); assert(pcall(require, "dap")); assert(pcall(require, "dap-go")); assert(pcall(require, "dap-python")); assert(pcall(require, "lazydev")); assert(pcall(require, "lint")); assert(pcall(require, "neotest")); assert(pcall(require, "schemastore")); assert(pcall(require, "sidekick")); assert(vim.fn.exists(":CodeCompanion") == 2); assert(vim.fn.exists(":DapViewToggle") == 2); assert(vim.fn.maparg("<leader>dc", "n") ~= ""); assert(vim.fn.maparg("<leader>ll", "n") ~= ""); assert(vim.fn.maparg("<leader>nd", "n") ~= ""); assert(vim.fn.maparg("<leader>nn", "n") ~= ""); assert(vim.fn.exists(":LspCopilotSignIn") == 2); assert(vim.fn.exists(":LspCopilotSignOut") == 2); assert(vim.env.CODECOMPANION_TOKEN_PATH == nil); assert(vim.env.NIXVIM_SHELL == [[${pkgs.nushell}/bin/nu]]); assert(vim.o.shell == [[${pkgs.nushell}/bin/nu]])' '+qall'

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

  assert(dap.configurations.rust[1].cwd == "''${workspaceFolder}")
  assert(dap.configurations.python[#dap.configurations.python].program == "''${workspaceFolder}/manage.py")
EOF

          ${self'.packages.nixvim}/bin/nvim --headless \
            "+lua dofile('${"$"}TMPDIR/nixvim-language-smoke.lua')" \
            "+qall"

          touch "$out"
        '';
        host-override-smoke = pkgs.writeText "host-override-smoke" ''
          user=${if overrideDesktop.config.repo.user.username == "adopter" then "adopter" else throw "repo.user override did not apply"}
          home=${if overrideHmUser.home.homeDirectory == "/home/adopter" then overrideHmUser.home.homeDirectory else throw "home-manager user override did not apply"}
          timezone=${if overrideDesktop.config.time.timeZone == "UTC" then overrideDesktop.config.time.timeZone else throw "timezone override did not apply"}
          locale=${if overrideDesktop.config.i18n.defaultLocale == "en_US.UTF-8" then overrideDesktop.config.i18n.defaultLocale else throw "locale override did not apply"}
          location=${if overrideHmUser.programs.noctalia-shell.settings.location.name == "New York, USA" then overrideDesktop.config.repo.location.name else throw "location override did not reach Home Manager"}
          output=${if (builtins.elemAt overrideDesktop.config.repo.niri.outputs 0).name == "HDMI-A-1" && (builtins.elemAt overrideDesktop.config.repo.niri.outputs 0).mode == "1920x1080@60" then "HDMI-A-1" else throw "niri output override did not apply"}
        '';
        niri-config = self.nixosConfigurations.desktop.config.environment.etc."niri/config.kdl".source;
        session-stack = pkgs.writeText "session-stack-check" ''
          greetd=${
            let
              rawCommand = self.nixosConfigurations.desktop.config.services.greetd.settings.default_session.command;
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
