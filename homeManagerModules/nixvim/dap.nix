{ pkgs, ... }:
{
  extraPlugins = with pkgs.vimPlugins; [
    nvim-dap
    nvim-dap-go
    nvim-dap-python
    nvim-dap-view
    nvim-dap-virtual-text
  ];
}
