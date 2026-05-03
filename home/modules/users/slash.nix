{ ... }:
{
  home.username = "slash";
  home.homeDirectory = "/home/slash";
  home.stateVersion = "25.11";

  nixpkgs.config = {
    allowUnfree = true;
  };
}
