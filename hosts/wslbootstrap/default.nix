{ pkgs, ... }:
{
  imports = [ ../../features/nixos/wsl.nix ];

  networking.hostName = "wslbootstrap";

  wsl.defaultUser = "bebr";

  users.users.bebr = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    home = "/home/bebr";
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
