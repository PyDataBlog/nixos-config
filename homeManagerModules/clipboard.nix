{ lib, pkgs, ... }:
let
  cliphistExe = lib.getExe pkgs.cliphist;
  wlPasteExe = "${pkgs.wl-clipboard}/bin/wl-paste";
  cliphistPick = pkgs.writeShellApplication {
    name = "cliphist-pick";
    runtimeInputs = [
      pkgs.cliphist
      pkgs.fzf
      pkgs.wl-clipboard
    ];
    text = ''
      selection="$(cliphist list | fzf --layout=reverse --border --prompt='clipboard> ' --no-sort)" || exit 0
      printf '%s' "$selection" | cliphist decode | wl-copy
    '';
  };
in
{
  home.packages = [
    pkgs.cliphist
    cliphistPick
  ];

  systemd.user.services.cliphist-store = {
    Unit = {
      Description = "Clipboard history watcher";
      PartOf = [ "niri.service" ];
      After = [ "niri.service" ];
      Requisite = [ "niri.service" ];
    };
    Service = {
      ExecStart = "${wlPasteExe} --watch ${cliphistExe} store";
      Restart = "always";
      RestartSec = 1;
    };
    Install.WantedBy = [ "niri.service" ];
  };

  systemd.user.services.cliphist-store-primary = {
    Unit = {
      Description = "Primary selection history watcher";
      PartOf = [ "niri.service" ];
      After = [ "niri.service" ];
      Requisite = [ "niri.service" ];
    };
    Service = {
      ExecStart = "${wlPasteExe} --primary --watch ${cliphistExe} store";
      Restart = "always";
      RestartSec = 1;
    };
    Install.WantedBy = [ "niri.service" ];
  };
}
