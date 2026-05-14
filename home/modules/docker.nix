{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # docker
    # docker-gc
    # docker-compose
    dockerfile-language-server
    docker-compose-language-service
  ];
}
