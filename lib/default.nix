{ inputs }:
let
  defaultSystem = "x86_64-linux";
  userDefinitions = import ../users;
  primaryUsername = userDefinitions.primary;
  primaryUser = userDefinitions.users.${primaryUsername};

  mkPkgs =
    {
      system,
      overlays ? [ ],
    }:
    import inputs.nixpkgs {
      inherit system overlays;
      config.allowUnfree = true;
    };

  mkPkgsStable =
    system:
    import inputs.nixpkgs-stable {
      inherit system;
      config.allowUnfree = true;
    };

  neovimNightlyOverlay = import ../overlays/neovim-nightly.nix { inherit inputs; };
in
{
  inherit
    defaultSystem
    mkPkgs
    mkPkgsStable
    neovimNightlyOverlay
    primaryUser
    primaryUsername
    userDefinitions
    ;
}
