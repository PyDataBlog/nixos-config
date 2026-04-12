{
  config,
  lib,
  osConfig,
  ...
}:
let
  cfg = osConfig.repo.obsidian;
  resolveVaultPath =
    path: if lib.hasPrefix "/" path then path else "${config.home.homeDirectory}/${path}";
  vaultDirs = map (vault: resolveVaultPath vault.path) cfg.vaults;
  extraDirs = lib.concatMap (
    vaultDir:
    lib.optionals (cfg.dailyNotes.enable && cfg.dailyNotes.folder != null) [
      "${vaultDir}/${cfg.dailyNotes.folder}"
    ]
    ++ lib.optionals (cfg.templates.enable && cfg.templates.folder != null) [
      "${vaultDir}/${cfg.templates.folder}"
    ]
    ++ lib.optionals (cfg.attachments.folder != null) [ "${vaultDir}/${cfg.attachments.folder}" ]
  ) vaultDirs;
  allDirs = vaultDirs ++ extraDirs;
  mkdirScript = lib.concatMapStringsSep "\n" (dir: "mkdir -p ${lib.escapeShellArg dir}") allDirs;
in
{
  home.sessionVariables = {
    OBSIDIAN_ENABLE = if cfg.enable then "1" else "0";
    OBSIDIAN_VAULTS_JSON = builtins.toJSON (
      map (vault: {
        inherit (vault) name path strict;
      }) cfg.vaults
    );
    OBSIDIAN_DAILY_NOTES_ENABLED = if cfg.dailyNotes.enable then "1" else "0";
    OBSIDIAN_DAILY_NOTES_FOLDER = if cfg.dailyNotes.folder == null then "" else cfg.dailyNotes.folder;
    OBSIDIAN_DAILY_NOTES_WORKDAYS_ONLY = if cfg.dailyNotes.workdaysOnly then "1" else "0";
    OBSIDIAN_DAILY_NOTES_TAGS_JSON = builtins.toJSON cfg.dailyNotes.defaultTags;
    OBSIDIAN_TEMPLATES_ENABLED = if cfg.templates.enable then "1" else "0";
    OBSIDIAN_TEMPLATES_FOLDER = if cfg.templates.folder == null then "" else cfg.templates.folder;
    OBSIDIAN_ATTACHMENTS_FOLDER = cfg.attachments.folder;
  };

  home.activation.ensureObsidianVaults = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${mkdirScript}
  '';
}
