{
  pkgs,
  pkgsStable ? null,
  lib ? pkgs.lib,
}:
let
  cli =
    (with pkgs; [
      age
      bat
      broot
      btop
      codex
      eza
      fd
      file
      fastfetch
      fzf
      gh
      git
      grc
      jq
      just
      lazygit
      mkpasswd
      nix-output-monitor
      p7zip
      ripgrep
      sops
      ssh-to-age
      tree-sitter
      trash-cli
      unzip
      wget
      wl-clipboard
      yazi
      zip
    ])
    ++ lib.optionals (pkgsStable != null) [ pkgsStable.curl ];
in
{
  inherit cli;

  desktop = with pkgs; [
    cudaPackages.cudatoolkit
    nvtopPackages.nvidia
  ];
}
