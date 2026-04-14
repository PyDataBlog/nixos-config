{
  config,
  lib,
  pkgs,
  repoLib,
  ...
}:
{
  imports = [
    ../../nixosModules/repo-user.nix
    ../../features/nixos/wsl.nix
  ];

  networking.hostName = "wslbootstrap";

  wsl.defaultUser = config.repo.user.username;

  security.sudo.wheelNeedsPassword = lib.mkForce false;

  repo.user = lib.mkDefault (
    repoLib.primaryUser
    // {
      extraGroups = [ "wheel" ];
    }
  );

  users.users.${config.repo.user.username} = {
    isNormalUser = true;
    description = config.repo.user.description;
    extraGroups = config.repo.user.extraGroups;
    home = config.repo.user.homeDirectory;
    shell = pkgs.bashInteractive;
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  environment.systemPackages = with pkgs; [
    curl
    git
    wget
  ];

  system.stateVersion = "25.11";
}
