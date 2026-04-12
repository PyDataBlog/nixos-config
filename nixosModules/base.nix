{
  config,
  inputs,
  lib,
  pkgs,
  pkgsStable,
  repoLib,
  ...
}:
let
  defaultUser = repoLib.primaryUser;
  defaultTimeZone = "Europe/Copenhagen";
  defaultLocale = "en_DK.UTF-8";
  defaultLocation = {
    latitude = "55.6761";
    longitude = "12.5683";
    name = "Copenhagen, Denmark";
  };
  defaultIdle = {
    lockSeconds = 600;
    monitorOffSeconds = 630;
  };
  defaultNightLight = {
    dayTemperature = 6500;
    nightTemperature = 3700;
  };
  mkLocaleSettings = locale: {
    LC_ADDRESS = locale;
    LC_IDENTIFICATION = locale;
    LC_MEASUREMENT = locale;
    LC_MONETARY = locale;
    LC_NAME = locale;
    LC_NUMERIC = locale;
    LC_PAPER = locale;
    LC_TELEPHONE = locale;
    LC_TIME = locale;
  };
  cfg = config.repo.user;
  localeCfg = config.repo.locale;
  secretsCfg = config.repo.secrets;
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.sops-nix.nixosModules.sops
  ];

  options.repo = {
    user = {
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

    locale = {
      timeZone = lib.mkOption {
        type = lib.types.str;
        default = defaultTimeZone;
        description = "Host timezone.";
      };

      defaultLocale = lib.mkOption {
        type = lib.types.str;
        default = defaultLocale;
        description = "Host default locale.";
      };

      extraLocaleSettings = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        description = "Host locale overrides merged on top of the default locale template.";
      };
    };

    location = {
      name = lib.mkOption {
        type = lib.types.str;
        default = defaultLocation.name;
        description = "Human-readable location name for desktop UI integrations.";
      };

      latitude = lib.mkOption {
        type = lib.types.str;
        default = defaultLocation.latitude;
        description = "Latitude used for location-aware desktop services.";
      };

      longitude = lib.mkOption {
        type = lib.types.str;
        default = defaultLocation.longitude;
        description = "Longitude used for location-aware desktop services.";
      };
    };

    idle = {
      lockSeconds = lib.mkOption {
        type = lib.types.ints.positive;
        default = defaultIdle.lockSeconds;
        description = "Idle timeout before locking the session.";
      };

      monitorOffSeconds = lib.mkOption {
        type = lib.types.ints.positive;
        default = defaultIdle.monitorOffSeconds;
        description = "Idle timeout before turning monitors off.";
      };
    };

    nightLight = {
      dayTemperature = lib.mkOption {
        type = lib.types.ints.positive;
        default = defaultNightLight.dayTemperature;
        description = "Daytime color temperature for location-aware night light.";
      };

      nightTemperature = lib.mkOption {
        type = lib.types.ints.positive;
        default = defaultNightLight.nightTemperature;
        description = "Nighttime color temperature for location-aware night light.";
      };
    };

    obsidian = {
      enable = lib.mkEnableOption "Obsidian desktop and Neovim integration";

      vaults = lib.mkOption {
        type = lib.types.listOf (
          lib.types.submodule {
            options = {
              name = lib.mkOption {
                type = lib.types.str;
                description = "Workspace name shown inside obsidian.nvim.";
              };

              path = lib.mkOption {
                type = lib.types.str;
                description = "Vault path. Relative paths are resolved against the user's home directory.";
              };

              strict = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = "Treat the workspace path itself as the vault root instead of searching parent directories.";
              };
            };
          }
        );
        default = [ ];
        description = "Configured Obsidian workspaces for the primary user.";
      };

      dailyNotes = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable daily-note support in obsidian.nvim.";
        };

        folder = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = "daily";
          description = "Folder for daily notes, relative to each vault root.";
        };

        workdaysOnly = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Use workday-aware yesterday/tomorrow navigation for daily notes.";
        };

        defaultTags = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ "daily-notes" ];
          description = "Default tags added to daily notes.";
        };
      };

      templates = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable template support in obsidian.nvim.";
        };

        folder = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = "templates";
          description = "Folder for templates, relative to each vault root.";
        };
      };

      attachments = {
        folder = lib.mkOption {
          type = lib.types.str;
          default = "attachments";
          description = "Folder for pasted images and attachments, relative to each vault root.";
        };
      };
    };

    secrets = {
      sopsFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Optional SOPS file containing host-level secrets for this machine.";
      };

      sopsFormat = lib.mkOption {
        type = lib.types.enum [
          "yaml"
          "json"
          "ini"
          "dotenv"
          "binary"
        ];
        default = "yaml";
        description = "Format of `repo.secrets.sopsFile` when it is set.";
      };

      userPasswordHashKey = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Optional SOPS key containing the hashed password for the primary user.";
      };
    };
  };

  config = {
    assertions = [
      {
        assertion = secretsCfg.userPasswordHashKey == null || secretsCfg.sopsFile != null;
        message = "Set repo.secrets.sopsFile when repo.secrets.userPasswordHashKey is used.";
      }
      {
        assertion = config.repo.idle.monitorOffSeconds > config.repo.idle.lockSeconds;
        message = "Set repo.idle.monitorOffSeconds higher than repo.idle.lockSeconds.";
      }
      {
        assertion = (!config.repo.obsidian.enable) || config.repo.obsidian.vaults != [ ];
        message = "Set at least one repo.obsidian.vaults entry when repo.obsidian.enable is true.";
      }
    ];

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.permittedInsecurePackages = [ "ventoy-gtk3-1.1.10" ];

    programs.nh = {
      enable = true;
      clean = {
        enable = true;
        dates = "weekly";
        extraArgs = "--keep 10 --optimise";
      };
    };

    networking.networkmanager.enable = true;

    services.openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PasswordAuthentication = true;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
      };
    };

    time.timeZone = localeCfg.timeZone;

    i18n.defaultLocale = localeCfg.defaultLocale;
    i18n.extraLocaleSettings =
      mkLocaleSettings localeCfg.defaultLocale // localeCfg.extraLocaleSettings;

    services.printing = {
      enable = true;
      drivers = [ pkgs.hplip ];
    };
    programs.system-config-printer.enable = true;

    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    services.xserver.xkb = {
      layout = "us,dk";
      options = "grp:alt_shift_toggle";
    };

    environment.shells = [ pkgs.nushell ];
    users.defaultUserShell = pkgs.nushell;

    sops = lib.mkIf (secretsCfg.sopsFile != null) {
      defaultSopsFile = secretsCfg.sopsFile;
      defaultSopsFormat = secretsCfg.sopsFormat;
      secrets = lib.optionalAttrs (secretsCfg.userPasswordHashKey != null) {
        "${secretsCfg.userPasswordHashKey}" = {
          neededForUsers = true;
        };
      };
    };

    programs.firefox.enable = true;

    users.users = {
      ${cfg.username} = {
        isNormalUser = true;
        description = cfg.description;
        extraGroups = cfg.extraGroups;
        home = cfg.homeDirectory;
        shell = pkgs.nushell;
      }
      // lib.optionalAttrs (secretsCfg.userPasswordHashKey != null) {
        hashedPasswordFile = config.sops.secrets.${secretsCfg.userPasswordHashKey}.path;
      };
    };

    home-manager = {
      backupFileExtension = "hm-backup";
      useGlobalPkgs = true;
      useUserPackages = true;
      sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
      extraSpecialArgs = {
        inherit inputs pkgsStable repoLib;
        userConfig = cfg;
      };
      users.${cfg.username} = import cfg.homeModule;
    };
  };
}
