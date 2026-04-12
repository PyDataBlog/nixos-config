{ pkgs, ... }:
let
  grammarPackages = with pkgs.vimPlugins.nvim-treesitter.grammarPlugins; [
    bash
    c
    cpp
    css
    diff
    dockerfile
    go
    gomod
    gosum
    gowork
    gotmpl
    graphql
    hcl
    helm
    html
    htmldjango
    http
    javascript
    json
    json5
    jsonnet
    latex
    lua
    luadoc
    luap
    markdown
    markdown_inline
    nix
    nu
    python
    query
    regex
    rust
    sql
    terraform
    toml
    tsx
    typescript
    vim
    vimdoc
    xml
    yaml
    zig
  ];
in
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
    grammarPackages = grammarPackages;
  };

  plugins.treesitter-textobjects.enable = true;
}
