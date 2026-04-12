{
  inputs,
  ...
}:
{
  imports = [
    inputs.nixos-wsl.nixosModules.default
    ../../nixosModules/corporate-ca.nix
  ];

  config = {
    wsl = {
      enable = true;
      interop.includePath = false;
      startMenuLaunchers = false;
    };
  };
}
