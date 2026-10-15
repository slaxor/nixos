{ pkgs, ... }:
{
  imports = [
    ../modules/ai
  ];

  home.packages = with pkgs; [
    algia
    vivid
    swappy
    satty
    tray-tui
    ghostty
    cavalier
    podman
    podman-tui
    podman-bootc
    podman-compose
    podman-desktop
  ];
}
