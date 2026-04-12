{
  inputs,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  noctalia = import ../lib/noctalia.nix {
    inherit inputs lib pkgs;
  };
  niriExe = lib.getExe pkgs.niri;
  inherit (noctalia) noctaliaIpcExe;
  wlsunsetExe = lib.getExe pkgs.wlsunset;
  location = osConfig.repo.location;
  idle = osConfig.repo.idle;
  nightLight = osConfig.repo.nightLight;
  swayidleSessionExe = lib.getExe (
    pkgs.writeShellApplication {
      name = "niri-idle-session";
      text = ''
        exec "${lib.getExe pkgs.swayidle}" -w \
          timeout ${toString idle.lockSeconds} '${noctaliaIpcExe} lockScreen lock' \
          timeout ${toString idle.monitorOffSeconds} '${niriExe} msg action power-off-monitors' resume '${niriExe} msg action power-on-monitors' \
          before-sleep '${noctaliaIpcExe} lockScreen lock'
      '';
    }
  );
in
{
  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 20;
    gtk.enable = true;
    x11.enable = true;
  };

  programs.noctalia-shell = {
    enable = true;
    settings = {
      bar = {
        density = "compact";
        position = "top";
        showCapsule = false;
        widgets = {
          left = [
            {
              id = "ControlCenter";
              useDistroLogo = true;
            }
            {
              id = "Network";
            }
            {
              id = "Bluetooth";
            }
          ];
          center = [
            {
              id = "Workspace";
              hideUnoccupied = false;
              labelMode = "index";
              showLabelsOnlyWhenOccupied = false;
            }
          ];
          right = [
            {
              id = "Battery";
              alwaysShowPercentage = false;
              warningThreshold = 30;
            }
            {
              id = "Clock";
              formatHorizontal = "HH:mm";
              formatVertical = "HH mm";
              useMonospacedFont = true;
              usePrimaryColor = true;
            }
          ];
        };
      };

      colorSchemes.predefinedScheme = "Nord";

      general = {
        radiusRatio = 0.2;
      };

      location = {
        monthBeforeDay = false;
        name = location.name;
      };
    };
  };

  systemd.user.services.swayidle = {
    Unit = {
      Description = "Idle management for Niri";
      PartOf = [ "niri.service" ];
      After = [ "niri.service" ];
      Requisite = [ "niri.service" ];
    };
    Service = {
      ExecStart = swayidleSessionExe;
      Restart = "on-failure";
    };
    Install.WantedBy = [ "niri.service" ];
  };

  systemd.user.services.wlsunset = {
    Unit = {
      Description = "Night light for Niri";
      PartOf = [ "niri.service" ];
      After = [ "niri.service" ];
      Requisite = [ "niri.service" ];
    };
    Service = {
      ExecStart = "${wlsunsetExe} -l ${location.latitude} -L ${location.longitude} -T ${toString nightLight.dayTemperature} -t ${toString nightLight.nightTemperature}";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "niri.service" ];
  };
}
