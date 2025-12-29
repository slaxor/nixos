{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    docker
  ];

  systemd.services.docker-create-wgnet = {
    description = "Create docker network wgnet if it doesn't exist";
    after = [ "docker.service" ];
    wants = [ "docker.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      if ! docker network inspect wgnet >/dev/null 2>&1; then
        docker network create wgnet
      fi
    '';
  };

  virtualisation.oci-containers.containers.wg-hub = {
    image = "lscr.io/linuxserver/wireguard:latest";

    ports = [ "51820:51820/udp" ];

    # Add NET_ADMIN & required WireGuard kernel sysctl
    extraOptions = [
      "--cap-add=NET_ADMIN"
      "--sysctl=net.ipv4.conf.all.src_valid_mark=1"
      "--network=wgnet"
    ];

    environment = {
      PUID = "1000";
      PGID = "1000";
      TZ = "UTC";
      ALLOWEDIPS = "0.0.0.0/0";
      SERVERURL = "auto";
      SERVERPORT = "51820";
    };

    volumes = [
      "wireguard-config:/config"
    ];
  };
}
