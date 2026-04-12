{ pkgs, ... }:
{
  networking.networkmanager.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  services.printing = {
    enable = true;
    drivers = [ pkgs.hplip ];
  };
  programs.system-config-printer.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.xserver.xkb = {
    layout = "us,dk";
    options = "grp:alt_shift_toggle";
  };

  programs.firefox.enable = true;
}
