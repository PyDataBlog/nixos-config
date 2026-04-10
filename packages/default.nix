{
  pkgs,
  pkgsStable ? null,
  lib ? pkgs.lib,
  claudeCodePkg,
  codexPkg,
}:
let
  cli =
    (with pkgs; [
      age
      ast-grep
      bat
      broot
      btop
      bubblewrap
      chafa
      direnv
      eza
      exiftool
      fd
      fastfetch
      ffmpeg
      file
      fzf
      gh
      git
      grpcurl
      grc
      hatch
      imagemagick
      jq
      just
      lazygit
      mediainfo
      mkpasswd
      nh
      nix-direnv
      nix-du
      nix-init
      nix-melt
      nix-output-monitor
      nix-tree
      nvd
      opencode
      openssl
      p7zip
      pandoc
      pkgs."poppler-utils"
      ripgrep
      sops
      ssh-to-age
      tectonic
      texlab
      tree-sitter
      trash-cli
      unzip
      uv
      websocat
      wget
      wl-clipboard
      yazi
      yt-dlp
      zip
    ])
    ++ [
      claudeCodePkg
      codexPkg
    ]
    ++ lib.optionals (pkgsStable != null) [ pkgsStable.curl ];
  kubernetes = with pkgs; [
    argocd
    cmctl
    fluxcd
    helm-docs
    helmfile
    k9s
    k3d
    kind
    kubectl
    kubecolor
    kubectx
    kubelogin-oidc
    kubernetes-helm
    kubeseal
    kustomize
    popeye
    stern
    talosctl
    trivy
  ];
  languages = with pkgs; [
    cargo
    clippy
    go
    nodejs
    python3
    rustc
    rustfmt
    sqlite
    terraform
    zig
  ];
in
{
  inherit cli;
  inherit kubernetes;
  inherit languages;

  desktop = with pkgs; [
    cudaPackages.cudatoolkit
    nvtopPackages.nvidia
    ventoy-full-gtk
  ];
}
