{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.repo.niri;
  system = pkgs.stdenv.hostPlatform.system;
  ghosttyExe = lib.getExe pkgs.ghostty;
  noctaliaExe = lib.getExe inputs.noctalia.packages.${system}.default;
  playerctlExe = lib.getExe pkgs.playerctl;
  renderOutput =
    output: ''
      output "${output.name}" {
          mode "${output.mode}"
          scale ${toString output.scale}
      }
    '';
  outputConfig = lib.concatStringsSep "\n\n" (map renderOutput cfg.outputs);
  startNoctaliaExe = lib.getExe (
    pkgs.writeShellApplication {
      name = "start-noctalia";
      runtimeInputs = [ pkgs.coreutils pkgs.gnugrep pkgs.procps ];
      text = ''
        current_uid="$(id -u)"
        current_root="$(dirname "$(dirname "${noctaliaExe}")")"
        current_config_path="$current_root/share/noctalia-shell"

        list_noctalia_pids() {
          for proc_dir in /proc/[0-9]*; do
            pid="''${proc_dir##*/}"

            if [ ! -r "$proc_dir/environ" ] || [ ! -L "$proc_dir/exe" ]; then
              continue
            fi

            if [ "$(stat -c '%u' "$proc_dir")" != "$current_uid" ]; then
              continue
            fi

            if ! grep -azq '^QS_CONFIG_PATH=.*/noctalia-shell\(/shell\.qml\)\?$' "$proc_dir/environ" 2>/dev/null; then
              continue
            fi

            qs_exe="$(readlink -f "$proc_dir/exe" 2>/dev/null || true)"
            case "''${qs_exe##*/}" in
              quickshell|.quickshell-wrapped)
                printf '%s\n' "$pid"
                ;;
              *)
                :
                ;;
            esac
          done
        }

        read_config_path() {
          tr '\0' '\n' </proc/"$1"/environ 2>/dev/null | grep '^QS_CONFIG_PATH=' | head -n 1 | cut -d= -f2-
        }

        kill_tree() {
          target="$1"
          for child in $(pgrep -P "$target" || true); do
            kill_tree "$child"
          done
          kill "$target" 2>/dev/null || true
        }

        keep_pid=""

        for pid in $(list_noctalia_pids | sort -rn); do
          config_path="$(read_config_path "$pid")"
          normalized_config_path="''${config_path%/shell.qml}"

          if [ -z "$keep_pid" ] && [ "$normalized_config_path" = "$current_config_path" ]; then
            keep_pid="$pid"
            continue
          fi

          kill_tree "$pid"

          for _ in $(seq 1 20); do
            if ! kill -0 "$pid" 2>/dev/null; then
              break
            fi
            sleep 0.1
          done
        done

        if [ -n "$keep_pid" ] && kill -0 "$keep_pid" 2>/dev/null; then
          exit 0
        fi

        exec "${noctaliaExe}"
      '';
    }
  );

  managedConfig = ''
    input {
        keyboard {
            xkb {}
            numlock
        }

        touchpad {
            tap
            natural-scroll
        }
    }

    ${outputConfig}

    cursor {
        xcursor-theme "Bibata-Modern-Ice"
        xcursor-size 20
    }

    layout {
        gaps 16
        center-focused-column "never"

        preset-column-widths {
            proportion 0.33333
            proportion 0.5
            proportion 0.66667
        }

        default-column-width { proportion 0.5; }

        focus-ring {
            width 4
            active-color "#88c0d0"
            inactive-color "#4c566a"
        }

        border {
            off
            width 4
            active-color "#8fbcbb"
            inactive-color "#4c566a"
            urgent-color "#bf616a"
        }

        shadow {
            softness 30
            spread 5
            offset x=0 y=5
            color "#2e3440aa"
        }

        struts {}
    }

    spawn-at-startup "${startNoctaliaExe}"

    hotkey-overlay {}

    screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

    window-rule {
        match app-id=r#"firefox$"# title="^Picture-in-Picture$"
        open-floating true
    }

    binds {
        Mod+Shift+Slash { show-hotkey-overlay; }

        Mod+T hotkey-overlay-title="Open a Terminal: ghostty" { spawn "${ghosttyExe}"; }
        Mod+Space hotkey-overlay-title="Toggle Noctalia Launcher" { spawn-sh "${noctaliaExe} ipc call launcher toggle"; }
        Mod+D hotkey-overlay-title="Toggle Noctalia Launcher" { spawn-sh "${noctaliaExe} ipc call launcher toggle"; }
        Mod+S hotkey-overlay-title="Toggle Noctalia Control Center" { spawn-sh "${noctaliaExe} ipc call controlCenter toggle"; }
        Mod+Comma hotkey-overlay-title="Open Noctalia Settings" { spawn-sh "${noctaliaExe} ipc call settings toggle"; }
        Super+Alt+L hotkey-overlay-title="Lock the Screen: Noctalia" { spawn-sh "${noctaliaExe} ipc call lockScreen lock"; }

        XF86AudioRaiseVolume allow-when-locked=true { spawn-sh "${noctaliaExe} ipc call volume increase"; }
        XF86AudioLowerVolume allow-when-locked=true { spawn-sh "${noctaliaExe} ipc call volume decrease"; }
        XF86AudioMute allow-when-locked=true { spawn-sh "${noctaliaExe} ipc call volume muteOutput"; }
        XF86AudioMicMute allow-when-locked=true { spawn-sh "${noctaliaExe} ipc call volume muteInput"; }
        XF86AudioPlay allow-when-locked=true { spawn "${playerctlExe}" "play-pause"; }
        XF86AudioStop allow-when-locked=true { spawn "${playerctlExe}" "stop"; }
        XF86AudioPrev allow-when-locked=true { spawn "${playerctlExe}" "previous"; }
        XF86AudioNext allow-when-locked=true { spawn "${playerctlExe}" "next"; }
        XF86MonBrightnessUp allow-when-locked=true { spawn-sh "${noctaliaExe} ipc call brightness increase"; }
        XF86MonBrightnessDown allow-when-locked=true { spawn-sh "${noctaliaExe} ipc call brightness decrease"; }

        Mod+O repeat=false { toggle-overview; }
        Mod+Q repeat=false { close-window; }

        Mod+Left { focus-column-left; }
        Mod+Down { focus-window-down; }
        Mod+Up { focus-window-up; }
        Mod+Right { focus-column-right; }
        Mod+H { focus-column-left; }
        Mod+J { focus-window-down; }
        Mod+K { focus-window-up; }
        Mod+L { focus-column-right; }

        Mod+Ctrl+Left { move-column-left; }
        Mod+Ctrl+Down { move-window-down; }
        Mod+Ctrl+Up { move-window-up; }
        Mod+Ctrl+Right { move-column-right; }
        Mod+Ctrl+H { move-column-left; }
        Mod+Ctrl+J { move-window-down; }
        Mod+Ctrl+K { move-window-up; }
        Mod+Ctrl+L { move-column-right; }

        Mod+Home { focus-column-first; }
        Mod+End { focus-column-last; }
        Mod+Ctrl+Home { move-column-to-first; }
        Mod+Ctrl+End { move-column-to-last; }

        Mod+Shift+Left { focus-monitor-left; }
        Mod+Shift+Down { focus-monitor-down; }
        Mod+Shift+Up { focus-monitor-up; }
        Mod+Shift+Right { focus-monitor-right; }
        Mod+Shift+H { focus-monitor-left; }
        Mod+Shift+J { focus-monitor-down; }
        Mod+Shift+K { focus-monitor-up; }
        Mod+Shift+L { focus-monitor-right; }

        Mod+Shift+Ctrl+Left { move-column-to-monitor-left; }
        Mod+Shift+Ctrl+Down { move-column-to-monitor-down; }
        Mod+Shift+Ctrl+Up { move-column-to-monitor-up; }
        Mod+Shift+Ctrl+Right { move-column-to-monitor-right; }
        Mod+Shift+Ctrl+H { move-column-to-monitor-left; }
        Mod+Shift+Ctrl+J { move-column-to-monitor-down; }
        Mod+Shift+Ctrl+K { move-column-to-monitor-up; }
        Mod+Shift+Ctrl+L { move-column-to-monitor-right; }

        Mod+Page_Down { focus-workspace-down; }
        Mod+Page_Up { focus-workspace-up; }
        Mod+U { focus-workspace-down; }
        Mod+I { focus-workspace-up; }
        Mod+Ctrl+Page_Down { move-column-to-workspace-down; }
        Mod+Ctrl+Page_Up { move-column-to-workspace-up; }
        Mod+Ctrl+U { move-column-to-workspace-down; }
        Mod+Ctrl+I { move-column-to-workspace-up; }

        Mod+Shift+Page_Down { move-workspace-down; }
        Mod+Shift+Page_Up { move-workspace-up; }
        Mod+Shift+U { move-workspace-down; }
        Mod+Shift+I { move-workspace-up; }

        Mod+WheelScrollDown cooldown-ms=150 { focus-workspace-down; }
        Mod+WheelScrollUp cooldown-ms=150 { focus-workspace-up; }
        Mod+Ctrl+WheelScrollDown cooldown-ms=150 { move-column-to-workspace-down; }
        Mod+Ctrl+WheelScrollUp cooldown-ms=150 { move-column-to-workspace-up; }
        Mod+WheelScrollRight { focus-column-right; }
        Mod+WheelScrollLeft { focus-column-left; }
        Mod+Ctrl+WheelScrollRight { move-column-right; }
        Mod+Ctrl+WheelScrollLeft { move-column-left; }
        Mod+Shift+WheelScrollDown { focus-column-right; }
        Mod+Shift+WheelScrollUp { focus-column-left; }
        Mod+Ctrl+Shift+WheelScrollDown { move-column-right; }
        Mod+Ctrl+Shift+WheelScrollUp { move-column-left; }

        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+5 { focus-workspace 5; }
        Mod+6 { focus-workspace 6; }
        Mod+7 { focus-workspace 7; }
        Mod+8 { focus-workspace 8; }
        Mod+9 { focus-workspace 9; }
        Mod+Ctrl+1 { move-column-to-workspace 1; }
        Mod+Ctrl+2 { move-column-to-workspace 2; }
        Mod+Ctrl+3 { move-column-to-workspace 3; }
        Mod+Ctrl+4 { move-column-to-workspace 4; }
        Mod+Ctrl+5 { move-column-to-workspace 5; }
        Mod+Ctrl+6 { move-column-to-workspace 6; }
        Mod+Ctrl+7 { move-column-to-workspace 7; }
        Mod+Ctrl+8 { move-column-to-workspace 8; }
        Mod+Ctrl+9 { move-column-to-workspace 9; }

        Mod+BracketLeft { consume-or-expel-window-left; }
        Mod+BracketRight { consume-or-expel-window-right; }
        Mod+Ctrl+Comma { consume-window-into-column; }
        Mod+Ctrl+Period { expel-window-from-column; }

        Mod+R { switch-preset-column-width; }
        Mod+Shift+R { switch-preset-window-height; }
        Mod+Ctrl+R { reset-window-height; }
        Mod+F { maximize-column; }
        Mod+Shift+F { fullscreen-window; }
        Mod+Ctrl+F { expand-column-to-available-width; }
        Mod+C { center-column; }
        Mod+Ctrl+C { center-visible-columns; }
        Mod+Minus { set-column-width "-10%"; }
        Mod+Equal { set-column-width "+10%"; }
        Mod+Shift+Minus { set-window-height "-10%"; }
        Mod+Shift+Equal { set-window-height "+10%"; }
        Mod+V { toggle-window-floating; }
        Mod+Shift+V { switch-focus-between-floating-and-tiling; }
        Mod+W { toggle-column-tabbed-display; }

        Print { screenshot; }
        Ctrl+Print { screenshot-screen; }
        Alt+Print { screenshot-window; }

        Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }
        Mod+Shift+E { quit; }
        Ctrl+Alt+Delete { quit; }
        Mod+Shift+P { power-off-monitors; }
    }
  '';

  managedConfigFile = pkgs.writeText "niri-config.kdl" managedConfig;
  validatedConfig = pkgs.runCommandLocal "niri-config.kdl" { nativeBuildInputs = [ pkgs.niri ]; } ''
    install -Dm0644 ${managedConfigFile} $out
    ${lib.getExe pkgs.niri} validate -c $out
  '';
in
{
  options.repo.niri.outputs = lib.mkOption {
    type = with lib.types; listOf (submodule {
      options = {
        name = lib.mkOption {
          type = str;
          description = "Niri output name.";
        };
        mode = lib.mkOption {
          type = str;
          description = "Niri output mode string.";
        };
        scale = lib.mkOption {
          type = either int float;
          default = 1;
          description = "Niri output scale factor.";
        };
      };
    });
    default = [ ];
    description = "Outputs rendered into the generated Niri config.";
  };

  config = {
    programs.niri.enable = true;

    environment.sessionVariables.NIRI_CONFIG = "/etc/niri/config.kdl";
    environment.etc."niri/config.kdl".source = validatedConfig;
  };
}
