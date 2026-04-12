{ pkgs, ... }:
{
  extraPlugins = with pkgs.vimPlugins; [
    pkgs.vimPlugins."FixCursorHold-nvim"
    neotest
    neotest-bash
    neotest-go
    neotest-python
    neotest-rust
    neotest-zig
    nvim-nio
  ];
}
