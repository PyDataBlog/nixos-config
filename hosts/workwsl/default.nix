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

  security.sudo.wheelNeedsPassword = lib.mkForce true;

  programs.nix-ld.enable = true;

  sops.age.keyFile = lib.mkDefault "${repoLib.primaryUser.homeDirectory}/.config/sops/age/keys.txt";

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

  system.stateVersion = "25.11";
}
