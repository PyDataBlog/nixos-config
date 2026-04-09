{
  primary = "bebr";

  users = {
    bebr = {
      username = "bebr";
      description = "bebr";
      homeDirectory = "/home/bebr";
      homeModule = ./home.nix;
      homeStateVersion = "25.11";
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
    };
  };
}
