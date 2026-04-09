{ config, ... }:
let
  cfg = config.repo.user;
in
{
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      features = {
        buildkit = true;
      };
    };
  };

  environment.pathsToLink = [ "/libexec/docker/cli-plugins" ];

  users.users = {
    ${cfg.username}.extraGroups = [ "docker" ];
  };
}
