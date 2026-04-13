{
  lib,
  repoLib,
  ...
}:
{
  imports = [
    ../../features/nixos/base.nix
    ../../features/nixos/wsl.nix
  ];

  networking.hostName = "workwsl";

  wsl.defaultUser = repoLib.primaryUser.username;

  users.mutableUsers = false;
  security.sudo.wheelNeedsPassword = lib.mkForce true;

  programs.nix-ld.enable = true;

  sops.age.keyFile = lib.mkDefault "${repoLib.primaryUser.homeDirectory}/.config/sops/age/keys.txt";

  repo.workNetwork.certificateFile = /home/bebr/zscaler.pem;

  repo.user = lib.mkDefault (
    repoLib.primaryUser
    // {
      homeModule = ../../users/workwsl.nix;
      extraGroups = [ "wheel" ];
    }
  );

  repo.obsidian = lib.mkDefault {
    enable = false;
    vaults = [ ];
  };

  repo.secrets = lib.mkDefault {
    sopsFile = ../../secrets/desktop.yaml;
    userPasswordHashKey = "user-password-hash";
  };

  nix.settings = {
    extra-substituters = [ "https://nix-community.cachix.org" ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  system.stateVersion = "25.11";
}
