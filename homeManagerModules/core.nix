{ lib, userConfig, ... }:
{
  home = {
    username = lib.mkForce userConfig.username;
    homeDirectory = lib.mkForce userConfig.homeDirectory;
    stateVersion = userConfig.homeStateVersion;

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  xdg.enable = true;

  programs.home-manager.enable = true;
}
