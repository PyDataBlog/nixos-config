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
      set -as terminal-features ",ghostty:RGB,screen-256color:RGB,tmux-256color:RGB,xterm-256color:RGB"
      set -g set-clipboard on

      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi V send-keys -X select-line
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
      k = "kubecolor";
      kubectl = "kubecolor";
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
    '';
  };

  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$nix_shell$line_break$character";
      character = {
        success_symbol = "[>](bold white)";
        error_symbol = "[x](bold red)";
      };
      directory = {
        truncation_length = 4;
        truncate_to_repo = false;
      };
      git_branch = {
        format = "[$branch]($style) ";
      };
      git_status = {
        format = "([$all_status$ahead_behind]($style) )";
      };
      nix_shell = {
        format = "[nix:$name]($style) ";
      };
    };
  };
}
