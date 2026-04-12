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

  wsl.defaultUser = "bebr";

  programs.nix-ld.enable = true;

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
    sopsFile = null;
    userPasswordHashKey = null;
  };

  system.stateVersion = "25.11";
}
