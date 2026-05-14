{ ... }:
{
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;
  imports = [
    ./modules/identity.nix
  ];
}
