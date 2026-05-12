{ inputs }:
let
  defaultSystem = "x86_64-linux";
  userDefinitions = import ../users;
  primaryUsername = userDefinitions.primary;
  primaryUser = userDefinitions.users.${primaryUsername};
  nixpkgsConfig = {
    allowUnfree = true;
    allowInsecurePredicate = pkg:
      builtins.elem (inputs.nixpkgs.lib.getName pkg) [ "ventoy-gtk3" ];
  };

  mkPkgs =
    {
      system,
      overlays ? [ ],
    }:
    import inputs.nixpkgs {
      inherit system overlays;
      config = nixpkgsConfig;
    };

  mkPkgsStable =
    system:
    import inputs.nixpkgs-stable {
      inherit system;
      config = nixpkgsConfig;
    };

  neovimNightlyOverlay = import ../overlays/neovim-nightly.nix { inherit inputs; };
in
{
  inherit
    defaultSystem
    mkPkgs
    mkPkgsStable
    neovimNightlyOverlay
    nixpkgsConfig
    primaryUser
    primaryUsername
    userDefinitions
    ;
}
