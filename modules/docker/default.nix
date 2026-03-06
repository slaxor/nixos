{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    docker
  ];

  # systemd.services.docker-create-wgnet = {
  # description = "Create docker network wgnet if it doesn't exist";
  # after = [ "docker.service" ];
  # wants = [ "docker.service" ];
  # serviceConfig.Type = "oneshot";
  # script = ''
  # if ! docker network inspect wgnet >/dev/null 2>&1; then
  # docker network create wgnet
  # fi
  # '';
  # };

  services.docker.enable = true;

  virtualisation = {
    docker = {
      enable = true;
      daemon.settings = {
        dns = [
          "8.8.8.8"
          "1.1.1.1"
        ];
      };
    };

    # oci-containers.containers.wg-hub = {
    # image = "lscr.io/linuxserver/wireguard:latest";
    # ports = [ "51820:51820/udp" ];
    # capAdd = [ "NET_ADMIN" ];
    # sysctls = {
    # "net.ipv4.conf.all.src_valid_mark" = "1";
    # };

    # extraOptions = [
    # "--network=wgnet"
    # ];

    # environment = {
    # PUID = "1000";
    # PGID = "1000";
    # TZ = "UTC";
    # SERVERURL = "wg.t5l.de";
    # SERVERPORT = "51820";
    # };

    # volumes = [
    # "wireguard-config:/config"
    # ];
    # };

    # volumes = [
    # "wireguard-config:/config"
    # ];
  };
}
