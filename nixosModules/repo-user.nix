{
  lib,
  repoLib,
  ...
}:
let
  defaultUser = repoLib.primaryUser;
in
{
  options.repo.user = {
    username = lib.mkOption {
      type = lib.types.str;
      default = defaultUser.username;
      description = "Primary Home Manager username for this host.";
    };

    description = lib.mkOption {
      type = lib.types.str;
      default = defaultUser.description;
      description = "Description for the primary user account.";
    };

    homeDirectory = lib.mkOption {
      type = lib.types.str;
      default = defaultUser.homeDirectory;
      description = "Home directory for the primary user profile.";
    };

    homeModule = lib.mkOption {
      type = lib.types.path;
      default = defaultUser.homeModule;
      description = "Home Manager module to import for the primary user.";
    };

    homeStateVersion = lib.mkOption {
      type = lib.types.str;
      default = defaultUser.homeStateVersion;
      description = "Home Manager state version for the primary user.";
    };

    extraGroups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = defaultUser.extraGroups;
      description = "Extra groups for the primary user account.";
    };
  };
}
