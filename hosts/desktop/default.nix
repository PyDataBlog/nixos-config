{
  lib,
  pkgs,
  repoLib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../features/nixos/base.nix
    ../../features/nixos/docker.nix
    ../../features/nixos/desktop.nix
    ../../features/nixos/niri-noctalia.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "desktop";

  sops.age.sshKeyPaths = lib.mkDefault [ "/etc/ssh/ssh_host_ed25519_key" ];

  repo.user = lib.mkDefault repoLib.primaryUser;
  repo.locale = lib.mkDefault {
    timeZone = "Europe/Copenhagen";
    defaultLocale = "en_DK.UTF-8";
  };
  repo.location = lib.mkDefault {
    name = "Copenhagen, Denmark";
    latitude = "55.6761";
    longitude = "12.5683";
  };
  repo.idle = lib.mkDefault {
    lockSeconds = 600;
    monitorOffSeconds = 630;
  };
  repo.nightLight = lib.mkDefault {
    dayTemperature = 6500;
    nightTemperature = 3700;
  };
  repo.obsidian = lib.mkDefault {
    enable = true;
    vaults = [
      {
        name = "personal";
        path = "Notes";
        strict = false;
      }
    ];
  };
  repo.secrets = lib.mkDefault {
    sopsFile = ../../secrets/desktop.yaml;
    userPasswordHashKey = "user-password-hash";
  };
  repo.niri.outputs = lib.mkDefault [
    {
      name = "DP-1";
      mode = "3440x1440@144.001";
      scale = 1;
    }
  ];

  system.stateVersion = "25.11";
}
