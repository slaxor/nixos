{ config, ... }:
let
  hub = import ../hare/wg-hub.nix;
  address = "10.13.0.19";
in
{
  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      "wghare/key" = { };
      "wghare/psk" = { };
    };
  };

  networking = {
    networkmanager.unmanaged = [ "wghare" ];
    wireguard.interfaces.wghare = {
      ips = [ "${address}/32" ];
      privateKeyFile = config.sops.secrets."wghare/key".path;
      peers = [
        {
          inherit (hub) publicKey endpoint;
          presharedKeyFile = config.sops.secrets."wghare/psk".path;
          allowedIPs = [ hub.network ];
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
