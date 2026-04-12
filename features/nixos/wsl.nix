{
  inputs,
  lib,
  ...
}:
{
  imports = [
    inputs.nixos-wsl.nixosModules.default
    ../../nixosModules/corporate-ca.nix
  ];

  config = {
    security.sudo.wheelNeedsPassword = lib.mkDefault false;

    wsl = {
      enable = true;
      interop.includePath = false;
      startMenuLaunchers = false;
    };
  };
}
