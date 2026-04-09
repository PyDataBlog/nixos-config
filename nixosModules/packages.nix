{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    codex
    docker-compose
    xwayland-satellite
  ];
}
