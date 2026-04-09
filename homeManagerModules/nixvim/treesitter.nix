{ pkgs, ... }:
{
  plugins.rainbow-delimiters = {
    enable = true;
    strategy = {
      "" = "global";
      nix = "global";
    };
    settings.highlight = [
      "RainbowDelimiterRed"
      "RainbowDelimiterYellow"
      "RainbowDelimiterBlue"
      "RainbowDelimiterOrange"
      "RainbowDelimiterGreen"
      "RainbowDelimiterViolet"
      "RainbowDelimiterCyan"
    ];
  };

  plugins.treesitter = {
    enable = true;
    folding.enable = false;
    highlight.enable = true;
    indent.enable = true;
    grammarPackages = pkgs.vimPlugins.nvim-treesitter.allGrammars;
  };

  plugins.treesitter-textobjects.enable = true;
}
