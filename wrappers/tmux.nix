{
  inputs,
  pkgs,
  pkgsStable,
}:
let
  lib = pkgs.lib;

  shellHome = inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    extraSpecialArgs = {
      inherit inputs pkgsStable;
    };
    modules = [
      inputs.nix-index-database.homeModules.default
      ../homeManagerModules/shell.nix
      {
        home.username = "portable";
        home.homeDirectory = "/home/portable";
        home.stateVersion = "25.11";
        xdg.enable = true;
        programs.home-manager.enable = true;
        home.sessionVariables = {
          EDITOR = "nvim";
          VISUAL = "nvim";
        };
      }
    ];
  };

  homeFiles = shellHome.config."home-files";
  nuConfig = "${homeFiles}/.config/nushell/config.nu";
  starshipConfig = "${homeFiles}/.config/starship.toml";
  tmuxConfig = "${homeFiles}/.config/tmux/tmux.conf";

  tmuxRuntimePackages = with pkgs; [
    bash
    bat
    btop
    carapace
    eza
    fastfetch
    fd
    file
    fzf
    git
    grc
    jq
    neovim
    nix-index
    nushell
    procps
    starship
    tmux
    wl-clipboard
    xsel
    zoxide
  ];
in
pkgs.runCommandLocal "portable-tmux" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
    mkdir -p "$out/bin" "$out/share"

    cp ${nuConfig} "$out/share/config.nu"
    chmod u+w "$out/share/config.nu"
    cat >> "$out/share/config.nu" <<EOF

  \$env.EDITOR = "nvim"
  \$env.VISUAL = "nvim"
  \$env.SHELL = "$out/bin/nu"
  EOF

    cp ${tmuxConfig} "$out/share/tmux.conf"
    chmod u+w "$out/share/tmux.conf"
    cat >> "$out/share/tmux.conf" <<EOF

  set -g default-shell "$out/bin/nu"
  EOF

    makeWrapper ${pkgs.nushell}/bin/nu "$out/bin/nu" \
      --add-flags "--config $out/share/config.nu" \
      --prefix PATH : "$out/bin:${lib.makeBinPath tmuxRuntimePackages}" \
      --set EDITOR nvim \
      --set SHELL "$out/bin/nu" \
      --set STARSHIP_CONFIG ${starshipConfig} \
      --set VISUAL nvim

    makeWrapper ${pkgs.tmux}/bin/tmux "$out/bin/tmux" \
      --add-flags "-f $out/share/tmux.conf" \
      --prefix PATH : "$out/bin:${lib.makeBinPath tmuxRuntimePackages}" \
      --set EDITOR nvim \
      --set SHELL "$out/bin/nu" \
      --set STARSHIP_CONFIG ${starshipConfig} \
      --set VISUAL nvim
''
