{ config, pkgs, ... }:
let
  regreetBackground = pkgs.writeText "regreet-nord-background.svg" ''
    <svg xmlns="http://www.w3.org/2000/svg" width="2560" height="1440" viewBox="0 0 2560 1440">
      <defs>
        <linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stop-color="#2e3440"/>
          <stop offset="50%" stop-color="#3b4252"/>
          <stop offset="100%" stop-color="#2a303c"/>
        </linearGradient>
        <radialGradient id="glowA" cx="0%" cy="0%" r="1">
          <stop offset="0%" stop-color="#88c0d0" stop-opacity="0.24"/>
          <stop offset="100%" stop-color="#88c0d0" stop-opacity="0"/>
        </radialGradient>
        <radialGradient id="glowB" cx="0%" cy="0%" r="1">
          <stop offset="0%" stop-color="#5e81ac" stop-opacity="0.22"/>
          <stop offset="100%" stop-color="#5e81ac" stop-opacity="0"/>
        </radialGradient>
        <linearGradient id="line" x1="0%" y1="0%" x2="100%" y2="0%">
          <stop offset="0%" stop-color="#eceff4" stop-opacity="0"/>
          <stop offset="50%" stop-color="#eceff4" stop-opacity="0.12"/>
          <stop offset="100%" stop-color="#eceff4" stop-opacity="0"/>
        </linearGradient>
      </defs>

      <rect width="2560" height="1440" fill="url(#bg)"/>

      <circle cx="340" cy="220" r="620" fill="url(#glowA)"/>
      <circle cx="2120" cy="1180" r="760" fill="url(#glowB)"/>

      <g opacity="0.55">
        <rect x="176" y="196" width="920" height="2" rx="1" fill="url(#line)"/>
        <rect x="1460" y="308" width="720" height="2" rx="1" fill="url(#line)"/>
        <rect x="1220" y="1120" width="940" height="2" rx="1" fill="url(#line)"/>
      </g>

      <g opacity="0.16" fill="none" stroke="#d8dee9" stroke-width="2">
        <path d="M0 1030 C 340 930, 610 930, 910 1030 S 1540 1130, 1880 1010 S 2320 850, 2560 940"/>
        <path d="M0 1145 C 300 1040, 640 1045, 960 1145 S 1600 1260, 1930 1145 S 2280 1035, 2560 1100"/>
      </g>
    </svg>
  '';
in
{
  services.xserver.enable = true;

  services.greetd.enable = true;

  programs.regreet = {
    enable = true;
    cageArgs = [
      "-s"
      "-m"
      "last"
    ];
    font = {
      package = pkgs.ubuntu-sans;
      name = "Ubuntu Sans";
      size = 15;
    };
    theme = {
      package = pkgs.gnome-themes-extra;
      name = "Adwaita-dark";
    };
    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };
    cursorTheme = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
    };
    settings = {
      background = {
        path = regreetBackground;
        fit = "Cover";
      };
      appearance.greeting_msg = "Welcome back";
      widget.clock = {
        format = "%a  %d.%m.%Y  ·  %H:%M";
        resolution = "1s";
        label_width = 220;
      };
      commands = {
        reboot = [
          "loginctl"
          "reboot"
        ];
        poweroff = [
          "loginctl"
          "poweroff"
        ];
      };
    };
    extraCss = ''
      window {
        background: transparent;
        color: #eceff4;
      }

      headerbar.titlebar {
        background: transparent;
        border: none;
        box-shadow: none;
        min-height: 28px;
        padding-top: 8px;
        padding-bottom: 0;
      }

      headerbar.titlebar label {
        color: transparent;
        font-size: 0;
        min-height: 0;
        opacity: 0;
      }

      headerbar.titlebar button,
      headerbar.titlebar windowcontrols {
        opacity: 0;
        min-width: 0;
        min-height: 0;
        margin: 0;
        padding: 0;
        border: none;
        background: transparent;
        box-shadow: none;
      }

      picture {
        background-color: #2e3440;
      }

      frame.background {
        background: alpha(#2e3440, 0.84);
        border: 1px solid alpha(#d8dee9, 0.08);
        border-radius: 22px;
        box-shadow: 0 24px 80px alpha(black, 0.38);
      }

      button,
      togglebutton,
      entry,
      combobox,
      dropdown {
        min-height: 42px;
        border-radius: 14px;
      }

      label {
        color: #eceff4;
      }

      entry,
      combobox,
      dropdown,
      button,
      togglebutton {
        background-image: none;
        box-shadow: none;
        border: 1px solid alpha(#81a1c1, 0.22);
        transition: 150ms ease;
      }

      entry,
      combobox,
      dropdown {
        background: alpha(#3b4252, 0.92);
        color: #eceff4;
      }

      entry:focus,
      combobox:focus,
      dropdown:focus,
      button:focus,
      togglebutton:focus {
        border-color: #88c0d0;
        box-shadow: 0 0 0 3px alpha(#88c0d0, 0.16);
      }

      button,
      togglebutton {
        background: alpha(#4c566a, 0.62);
        color: #eceff4;
      }

      button:hover,
      togglebutton:hover {
        background: alpha(#5e81ac, 0.42);
      }

      togglebutton:checked {
        background: #81a1c1;
        border-color: #88c0d0;
        color: #2e3440;
      }

      button.suggested-action {
        background: #5e81ac;
        color: #eceff4;
        border-color: alpha(#88c0d0, 0.32);
      }

      button.suggested-action:hover {
        background: #6a8db5;
      }

      button.destructive-action {
        background: alpha(#bf616a, 0.18);
        border-color: alpha(#bf616a, 0.28);
        color: #eceff4;
      }

      button.destructive-action:hover {
        background: alpha(#bf616a, 0.28);
      }

      frame.background label {
        text-shadow: 0 1px 2px alpha(black, 0.18);
      }

      infobar {
        border-radius: 16px;
      }

      infobar.error {
        background: alpha(#bf616a, 0.18);
        color: #eceff4;
      }

      selection {
        background-color: #88c0d0;
        color: #2e3440;
      }
    '';
  };

  services.libinput.enable = true;
  services.gvfs.enable = true;
  security.polkit.enable = true;
  programs.dconf.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

  hardware.nvidia-container-toolkit.enable = true;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    bibata-cursors
    nvidia-container-toolkit
  ];

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    nerd-fonts.symbols-only
    ubuntu-classic
    ubuntu-sans
  ];
}
