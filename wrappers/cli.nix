{
  inputs,
  pkgs,
  system,
  pkgsStable,
}:
let
  lib = pkgs.lib;
  repoPackages = import ../packages {
    inherit pkgs pkgsStable lib;
    claudeCodePkg = inputs.claude-code-nix.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;
    codexPkg = inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.codex;
  };

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

  nixvim = import ./nixvim.nix {
    inherit
      inputs
      lib
      pkgs
      system
      pkgsStable
      ;
  };

  cliRuntimePackages = repoPackages.cli ++ repoPackages.languages ++ repoPackages.kubernetes ++ [
    pkgs.carapace
    pkgs.nix-index
    pkgs.nushell
    pkgs.starship
    pkgs.tmux
    pkgs.zoxide
  ];
in
pkgs.runCommandLocal "portable-cli" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
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

    makeWrapper ${nixvim}/bin/nvim "$out/bin/nvim" \
      --prefix PATH : "$out/bin:${lib.makeBinPath cliRuntimePackages}" \
      --set EDITOR nvim \
      --set NIXVIM_SHELL "$out/bin/nu" \
      --set SHELL "$out/bin/nu" \
      --set STARSHIP_CONFIG ${starshipConfig} \
      --set UV_NO_MANAGED_PYTHON 1 \
      --set UV_PYTHON_DOWNLOADS never \
      --set VISUAL nvim

    ln -s "$out/bin/nvim" "$out/bin/vim"
    ln -s "$out/bin/nvim" "$out/bin/vi"

    makeWrapper ${pkgs.tmux}/bin/tmux "$out/bin/tmux" \
      --add-flags "-f $out/share/tmux.conf" \
      --prefix PATH : "$out/bin:${lib.makeBinPath cliRuntimePackages}" \
      --set EDITOR nvim \
      --set NIXVIM_SHELL "$out/bin/nu" \
      --set SHELL "$out/bin/nu" \
      --set STARSHIP_CONFIG ${starshipConfig} \
      --set UV_NO_MANAGED_PYTHON 1 \
      --set UV_PYTHON_DOWNLOADS never \
      --set VISUAL nvim

    makeWrapper ${pkgs.nushell}/bin/nu "$out/bin/nu" \
      --add-flags "--config $out/share/config.nu" \
      --prefix PATH : "$out/bin:${lib.makeBinPath cliRuntimePackages}" \
      --set EDITOR nvim \
      --set NIXVIM_SHELL "$out/bin/nu" \
      --set SHELL "$out/bin/nu" \
      --set STARSHIP_CONFIG ${starshipConfig} \
      --set UV_NO_MANAGED_PYTHON 1 \
      --set UV_PYTHON_DOWNLOADS never \
      --set VISUAL nvim

    ln -s "$out/bin/nu" "$out/bin/portable-cli"
''
