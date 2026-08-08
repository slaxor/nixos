{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    iw
    iwd
    iwqr
    iwmenu
    wireguard-tools
  ];

  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      "wghare/key" = { };
      "wghare/psk" = { };
    };
  };

  networking = {
    hostName = "kea";
    usePredictableInterfaceNames = false;
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
        80
        443
      ];
      allowedUDPPorts = [
        53
        68
      ];
      allowedTCPPortRanges = [
        {
          from = 32768;
          to = 65535;
        }
      ];
      allowedUDPPortRanges = [
        {
          from = 32768;
          to = 65535;
        }
      ];

      trustedInterfaces = [
        "cilium_host"
        "cilium_net"
        "cilium_vxlan"
        "lxc+"
        "wghare"
      ];
      checkReversePath = false;
    };
    networkmanager = {
      enable = true;
      unmanaged = [
        "wghare"
      ];
      wifi = {
        powersave = false;
        backend = "iwd";
      };
      dns = "none";
    };

    wireguard.interfaces.wghare = {
      ips = [ "10.13.0.17/32" ];
      listenPort = 51820;
      privateKeyFile = config.sops.secrets."wghare/key".path;
      peers = [
        {
          publicKey = "3GPB7wIX/lWLV5C54teL0D0/FvhOgJXazx8Fsv+ZbH0=";
          presharedKeyFile = config.sops.secrets."wghare/psk".path;
          endpoint = "wg.m11s.de:51820";
          persistentKeepalive = 25;
          allowedIPs = [
            "10.13.0.0/24"
            "192.168.117.0/24"
            "192.168.178.0/24"
            "192.168.181.0/24"
          ];
        }
      ];
      postSetup = ''
        ip route replace 10.13.0.0/24 dev wghare metric 1100
        ip route replace 192.168.117.0/24 via 10.13.0.1 dev wghare metric 1100
        ip route replace 192.168.178.0/24 via 10.13.0.1 dev wghare metric 1100
        ip route replace 192.168.181.0/24 via 10.13.0.1 dev wghare metric 1100
      '';
      # postShutdown = ''
      # '';
    };
  };
}
