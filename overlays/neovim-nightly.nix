{ inputs }:
let
  upstream = inputs.neovim-nightly-overlay.overlays.default;
in
final: prev:
let
  upstreamPkgs = prev // (upstream final prev);
  neovimUnwrappedToken = "__NEOVIM_UNWRAPPED__";
  desktopBlock = ''
    rm $out/share/applications/nvim.desktop
    substitute ${neovimUnwrappedToken}/share/applications/nvim.desktop $out/share/applications/nvim.desktop \
      --replace-warn 'Name=Neovim' 'Name=Neovim wrapper'
  '';
  guardedDesktopBlock = ''
    if [ -f ${neovimUnwrappedToken}/share/applications/nvim.desktop ]; then
      rm -f $out/share/applications/nvim.desktop
      substitute ${neovimUnwrappedToken}/share/applications/nvim.desktop $out/share/applications/nvim.desktop \
        --replace-warn 'Name=Neovim' 'Name=Neovim wrapper'
    fi
  '';
  patchedWrapNeovimUnstable =
    neovim-unwrapped: attrs:
    ((upstreamPkgs.wrapNeovimUnstable neovim-unwrapped attrs).overrideAttrs (old: {
      postBuild =
        builtins.replaceStrings
          [
            (builtins.replaceStrings [ neovimUnwrappedToken ] [ "${neovim-unwrapped}" ] desktopBlock)
          ]
          [
            (builtins.replaceStrings [ neovimUnwrappedToken ] [ "${neovim-unwrapped}" ] guardedDesktopBlock)
          ]
          (old.postBuild or "");
    }));
in
(upstream final prev)
// {
  wrapNeovimUnstable = patchedWrapNeovimUnstable;
  neovimUtils = final.callPackage "${inputs.nixpkgs}/pkgs/applications/editors/neovim/utils.nix" {
    lua = final.lua5_1;
  };
  wrapNeovim =
    neovim-unwrapped: final.lib.makeOverridable (final.neovimUtils.legacyWrapper neovim-unwrapped);
  neovim = final.wrapNeovim final.neovim-unwrapped { };
}
