{
  pkgs,
  pkgsStable ? null,
  lib ? pkgs.lib,
  claudeCodePkg,
  codexPkg,
}:
let
  kubectlWrapped = pkgs.writeShellApplication {
    name = "kubectl";
    runtimeInputs = [
      pkgs.kubecolor
      pkgs.kubectl
    ];
    text = ''
      if [ -t 1 ] && [ -z "''${NO_COLOR-}" ]; then
        exec ${pkgs.kubecolor}/bin/kubecolor "$@"
      fi

      exec ${pkgs.kubectl}/bin/kubectl "$@"
    '';
  };
  cli =
    (with pkgs; [
      age
      act
      ast-grep
      azure-cli
      azure-storage-azcopy
      bat
      broot
      btop
      bubblewrap
      cargo-release
      chafa
      cmake
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
      glow
      grpcurl
      grc
      hatch
      helix
      imagemagick
      jq
      just
      lazygit
      mermaid-cli
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
      presenterm
      ripgrep
      rich-cli
      sops
      ssh-to-age
      tectonic
      texlab
      timg
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
    kubectlWrapped
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
  inherit kubectlWrapped;

  desktop = with pkgs; [
    antigravity
    cudaPackages.cudatoolkit
    nvtopPackages.nvidia
    ventoy-full-gtk
    vscode
  ];
}
