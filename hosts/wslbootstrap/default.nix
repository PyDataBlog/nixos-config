{
  lib,
  pkgs,
  repoLib,
  ...
}:
{
  imports = [ ../../features/nixos/wsl.nix ];

  networking.hostName = "wslbootstrap";

  wsl.defaultUser = repoLib.primaryUser.username;

  security.sudo.wheelNeedsPassword = lib.mkForce false;

  users.users.${repoLib.primaryUser.username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    home = repoLib.primaryUser.homeDirectory;
    shell = pkgs.bashInteractive;
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  environment.systemPackages = with pkgs; [
    curl
    gh
    git
    wget
  ];

  system.stateVersion = "25.11";
}
