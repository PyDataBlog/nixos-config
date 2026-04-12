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
  lfWrapped = import ../wrappers/lf.nix { inherit pkgs; };
  jjWrapped = import ../wrappers/jj.nix { inherit pkgs; };
  qalcWrapped = import ../wrappers/qalc.nix { inherit pkgs; };
  cli =
    (with pkgs; [
      age
      ast-grep
      bat
      broot
      btop
      bubblewrap
      cargo-release
      cmake
      direnv
      eza
      fd
      fastfetch
      file
      fzf
      gh
      git
      grpcurl
      grc
      hatch
      helix
      jjWrapped
      jq
      just
      k3d
      kubectlWrapped
      lazygit
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
      python3
      qalcWrapped
      ripgrep
      sops
      ssh-to-age
      tree-sitter
      trash-cli
      unzip
      uv
      websocat
      wget
      wl-clipboard
      yazi
      zip
    ])
    ++ [
      claudeCodePkg
      codexPkg
    ]
    ++ lib.optionals (pkgsStable != null) [ pkgsStable.curl ];
  cloudOps = with pkgs; [
    act
    azure-cli
    azure-storage-azcopy
  ];
  mediaDocs = with pkgs; [
    chafa
    exiftool
    ffmpeg
    glow
    imagemagick
    mermaid-cli
    mediainfo
    pandoc
    pkgs."poppler-utils"
    presenterm
    rich-cli
    tectonic
    texlab
    timg
    yt-dlp
  ];
  notes = with pkgs; [
    obsidian-export
  ];
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
    nixd
    nixfmt
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
  inherit cloudOps;
  inherit mediaDocs;
  inherit notes;
  inherit kubernetes;
  inherit languages;
  inherit lfWrapped;
  inherit jjWrapped;
  inherit kubectlWrapped;
  inherit qalcWrapped;

  desktop = with pkgs; [
    antigravity
    cudaPackages.cudatoolkit
    nvtopPackages.nvidia
    ventoy-full-gtk
    vscode
  ];
}
