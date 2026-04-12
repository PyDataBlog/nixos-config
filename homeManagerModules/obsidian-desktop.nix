{
  lib,
  osConfig,
  ...
}:
let
  cfg = osConfig.repo.obsidian;
in
lib.mkIf cfg.enable {
  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/obsidian" = [ "obsidian.desktop" ];
  };
  xdg.mimeApps.associations.added = {
    "x-scheme-handler/obsidian" = [ "obsidian.desktop" ];
  };
}
