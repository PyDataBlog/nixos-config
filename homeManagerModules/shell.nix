{ pkgs, ... }:
{
  home.sessionVariables = {
    UV_NO_MANAGED_PYTHON = "1";
    UV_PYTHON_DOWNLOADS = "never";
  };

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    clock24 = true;
    escapeTime = 0;
    focusEvents = true;
    historyLimit = 100000;
    keyMode = "vi";
    mouse = true;
    sensibleOnTop = true;
    terminal = "tmux-256color";
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      {
        plugin = yank;
        extraConfig = ''
          set -g @yank_selection 'clipboard'
          set -g @yank_selection_mouse 'clipboard'
        '';
      }
      {
        plugin = tmux-sessionx;
        extraConfig = ''
          set -g @sessionx-bind 'T'
          set -g @sessionx-fzf-builtin-tmux 'on'
          set -g @sessionx-preview-location 'right'
          set -g @sessionx-preview-ratio '55%'
          set -g @sessionx-window-height '85%'
          set -g @sessionx-window-width '75%'
          set -g @sessionx-zoxide-mode 'on'
        '';
      }
      {
        plugin = dracula;
        extraConfig = ''
          set -g @dracula-cpu-usage-label " "
          set -g @dracula-border-contrast true
          set -g @dracula-left-icon-padding 1
          set -g @dracula-plugins "cpu-usage ram-usage time"
          set -g @dracula-ram-usage-label " "
          set -g @dracula-refresh-rate 10
          set -g @dracula-show-empty-plugins false
          set -g @dracula-show-flags true
          set -g @dracula-show-left-icon "#h"
          set -g @dracula-show-powerline false
          set -g @dracula-show-timezone false
          set -g @dracula-time-format "%d.%m.%Y %R"
        '';
      }
    ];
    extraConfig = ''
      set -g status-position top
      set -as terminal-features ",ghostty:RGB,clipboard,screen-256color:RGB,clipboard,tmux-256color:RGB,clipboard,xterm-256color:RGB,clipboard"
      set -g allow-passthrough on
      set -g set-clipboard on

      bind-key r run-shell "${pkgs.bash}/bin/bash -lc 'for f in $(tmux display-message -p \"#{config_files}\" | tr \",\" \" \"); do [ -r \"$f\" ] && tmux source-file \"$f\"; done; tmux display-message \"tmux config reloaded\"'"
      bind-key -T copy-mode-vi Enter send-keys -X copy-selection-and-cancel
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi V send-keys -X select-line
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
      bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-selection-and-cancel
    '';
  };

  programs.carapace = {
    enable = true;
    enableNushellIntegration = true;
    ignoreCase = true;
  };

  programs.direnv = {
    enable = true;
    enableNushellIntegration = true;
    nix-direnv.enable = true;
  };

  programs.nix-index = {
    enableNushellIntegration = true;
  };

  programs.nix-index-database = {
    comma.enable = true;
  };

  programs.zoxide = {
    enable = true;
    enableNushellIntegration = true;
  };

  programs.nushell = {
    enable = true;
    settings = {
      show_banner = false;
      edit_mode = "vi";
      history = {
        file_format = "sqlite";
        max_size = 1000000;
        sync_on_enter = true;
      };
      completions = {
        algorithm = "fuzzy";
        case_sensitive = false;
        partial = true;
        quick = true;
      };
      cursor_shape = {
        emacs = "line";
        vi_insert = "line";
        vi_normal = "block";
      };
    };
    shellAliases = {
      cat = "bat --paging=never --style=plain";
      cc = "claude";
      claudecode = "claude";
      g = "git";
      k = "kubectl";
      ls = "eza --icons=always";
      ll = "eza -la --icons=always";
      la = "eza -a --icons=always";
      lt = "eza --tree --icons=always";
      oc = "opencode";
      tree = "eza --tree --icons=always";
      v = "nvim";
      vi = "nvim";
      vim = "nvim";
    };
    extraConfig = ''
      $env.config.buffer_editor = "nvim"
      $env.PROMPT_INDICATOR = ""
      $env.PROMPT_INDICATOR_VI_INSERT = ""
      $env.PROMPT_INDICATOR_VI_NORMAL = "  "
      $env.PROMPT_MULTILINE_INDICATOR = "⋮ "

      def "nu-complete k3d" [context: string] {
        let trimmed = ($context | str trim --left)
        let args = (
          $trimmed
          | split row " "
          | skip 1
        )
        let args = if ($trimmed | str ends-with " ") {
          $args | append ""
        } else {
          $args
        }

        let result = (^k3d __complete ...$args | complete)
        let lines = ($result.stdout | lines | where {|line| $line != "" })

        if ($lines | is-empty) {
          return []
        }

        let last_line = ($lines | last)
        let candidates = if ($last_line | str starts-with ":") {
          $lines | first (($lines | length) - 1)
        } else {
          $lines
        }

        if ($candidates | is-empty) {
          return []
        }

        $candidates | each {|line|
          let parts = ($line | split row "\t")
          if (($parts | length) > 1) {
            {
              value: ($parts | first)
              description: ($parts | skip 1 | str join " ")
            }
          } else {
            { value: ($parts | first) }
          }
        }
      }

      # Keep k3d completion independent from carapace hook ordering by using a
      # wrapped Nushell command with an explicit completion source.
      def --wrapped k3d [...rest: string@"nu-complete k3d"] {
        ^${pkgs.k3d}/bin/k3d ...$rest
      }
    '';
  };

  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$package$c$cpp$python$golang$rust$nodejs$lua$julia$rlang$php$ruby$zig$terraform$docker_context$nix_shell$line_break$character";
      right_format = "$kubernetes";
      character = {
        success_symbol = "[❯](bold cyan)";
        error_symbol = "[❯](bold red)";
      };
      directory = {
        format = "[󰉋 $path]($style)[$read_only]($read_only_style) ";
        read_only = " 󰌾";
        truncation_length = 4;
        truncate_to_repo = false;
      };
      git_branch = {
        format = "[$symbol$branch]($style) ";
        symbol = " ";
      };
      git_status = {
        format = "([$all_status$ahead_behind]($style) )";
      };
      package = {
        format = "[$symbol$version]($style) ";
        symbol = "󰏗 ";
      };
      c = {
        format = "[$symbol$version]($style) ";
        symbol = " ";
      };
      cpp = {
        format = "[$symbol$version]($style) ";
        symbol = " ";
      };
      python = {
        format = "[$symbol$version]($style) ";
        symbol = " ";
      };
      golang = {
        format = "[$symbol$version]($style) ";
        symbol = " ";
      };
      rust = {
        format = "[$symbol$version]($style) ";
        symbol = " ";
      };
      nodejs = {
        format = "[$symbol$version]($style) ";
        symbol = " ";
      };
      lua = {
        format = "[$symbol$version]($style) ";
        symbol = " ";
      };
      julia = {
        format = "[$symbol$version]($style) ";
        symbol = " ";
      };
      rlang = {
        format = "[$symbol$version]($style) ";
        symbol = "󰟔 ";
      };
      php = {
        format = "[$symbol$version]($style) ";
        symbol = " ";
      };
      ruby = {
        format = "[$symbol$version]($style) ";
        symbol = " ";
      };
      zig = {
        format = "[$symbol$version]($style) ";
        symbol = " ";
      };
      terraform = {
        format = "[$symbol$version]($style) ";
        symbol = " ";
      };
      docker_context = {
        format = "[$symbol$context]($style) ";
        symbol = " ";
      };
      nix_shell = {
        format = "[$symbol$name]($style) ";
        symbol = " ";
      };
      kubernetes = {
        disabled = false;
        format = "[$symbol$context(::$namespace)]($style)";
        style = "bold cyan";
        symbol = "󱃾 ";
        contexts = [
          {
            context_pattern = "k3d-(?P<cluster>[\\w-]+)";
            context_alias = "k3d:$cluster";
            style = "bold green";
          }
          {
            context_pattern = "kind-(?P<cluster>[\\w-]+)";
            context_alias = "kind:$cluster";
            style = "bold green";
          }
          {
            context_pattern = "minikube";
            context_alias = "minikube";
            style = "bold green";
          }
          {
            context_pattern = "docker-desktop";
            context_alias = "docker-desktop";
            style = "bold green";
          }
          {
            context_pattern = ".*(prod|production).*";
            style = "bold red";
          }
          {
            context_pattern = ".*(stage|staging).*";
            style = "bold yellow";
          }
          {
            context_pattern = ".*(dev|development).*";
            style = "bold blue";
          }
        ];
      };
    };
  };
}
