{ ... }:
{
  home.sessionVariables.TERMINAL = "ghostty";

  programs.ghostty = {
    enable = true;
    settings = {
      background-opacity = 0.92;
      background-opacity-cells = true;
      copy-on-select = "clipboard";
      confirm-close-surface = false;
      font-family = "Ubuntu Mono";
      font-size = 14;
      gtk-titlebar = false;
      mouse-hide-while-typing = true;
      notify-on-command-finish = "unfocused";
      notify-on-command-finish-action = "no-bell,notify";
      shell-integration-features = "no-cursor,ssh-env";
      theme = "TokyoNight Storm";
      window-padding-balance = true;
      window-padding-x = 12;
      window-padding-y = 10;
    };
  };
}
