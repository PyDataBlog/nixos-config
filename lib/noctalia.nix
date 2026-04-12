{
  inputs,
  lib,
  pkgs,
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  noctaliaExe = lib.getExe inputs.noctalia.packages.${system}.default;
  noctaliaProcessLib = ''
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

    current_noctalia_pid() {
      for pid in $(list_noctalia_pids | sort -rn); do
        config_path="$(read_config_path "$pid")"
        normalized_config_path="''${config_path%/shell.qml}"

        if [ "$normalized_config_path" = "$current_config_path" ] && kill -0 "$pid" 2>/dev/null; then
          printf '%s\n' "$pid"
          return 0
        fi
      done

      return 1
    }
  '';
  startNoctaliaExe = lib.getExe (
    pkgs.writeShellApplication {
      name = "start-noctalia";
      runtimeInputs = [
        pkgs.coreutils
        pkgs.gnugrep
        pkgs.procps
      ];
      text = ''
        ${noctaliaProcessLib}

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
  noctaliaIpcExe = lib.getExe (
    pkgs.writeShellApplication {
      name = "noctalia-ipc";
      runtimeInputs = [
        pkgs.coreutils
        pkgs.gnugrep
        pkgs.procps
      ];
      text = ''
        ${noctaliaProcessLib}

        "${startNoctaliaExe}" >/dev/null 2>&1 &

        for _ in $(seq 1 50); do
          if current_noctalia_pid >/dev/null; then
            exec "${noctaliaExe}" ipc call "$@"
          fi
          sleep 0.1
        done

        exec "${noctaliaExe}" ipc call "$@"
      '';
    }
  );
in
{
  inherit noctaliaExe noctaliaIpcExe startNoctaliaExe;
}
