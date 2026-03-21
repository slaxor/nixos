{
  networking = {
    nftables = {
      enable = true;
      ruleset = ''
        table inet filter {
          chain input {
            type filter hook input priority 0; policy drop;
            iif lo accept
            ct state established,related accept
            ip protocol icmp accept
            ip6 nexthdr icmpv6 accept
            udp dport 51820 accept
            tcp dport 22 accept
            # tmate — public
            tcp dport 2222 accept
            tcp dport { 80, 443 } accept
            iifname "wg0" accept
            ip saddr 10.42.0.0/16 accept
            ip saddr 10.43.0.0/16 accept
            tcp dport { 6443, 12000 } drop
            udp dport 53 accept
            tcp dport 53 accept
          }

          chain forward {
            type filter hook forward priority 0; policy accept;
          }

          chain output {
            type filter hook output priority 0; policy accept;
          }
        }
      '';
    };
    firewall = {
      enable = false;
      # backend = "nftables"; # use nftables instead of iptables
      # extraCommands = lib.mkForce "";
      allowedTCPPorts = [
        22
        80
        443
        2222
      ];
      allowedUDPPorts = [ 53 ]; # DNS
      trustedInterfaces = [
        "cilium_host"
        "cilium_net"
        "cilium_vxlan"
        "lxc+"
        "wg0"
      ];
      checkReversePath = false;
    };
    networkmanager.enable = false;
    useDHCP = false;
    interfaces = {
      "eno1" = {
        ipv4.addresses = [
          {
            address = "144.76.195.142";
            prefixLength = 27;
          }
        ];
        ipv6.addresses = [
          {
            address = "2a01:4f8:200:7181::1";
            prefixLength = 64;
          }
        ];
      };
    };

    wireguard.interfaces.wg0 = {
      ips = [ "10.13.0.1/24" ];
      listenPort = 51820;
      privateKeyFile = "/etc/wireguard/privatekey";

      peers = [
        {
          presharedKeyFile = "/etc/wireguard/slash@kea.psk";
          publicKey = "Ah8uUMZI5pbrHmn2D2l74G2IW3hcjtEWXtRFXebMLDg=";
          allowedIPs = [ "10.13.0.2/32" ];
        }
      ];
    };

    defaultGateway = {
      address = "144.76.195.129";
      interface = "eno1";
    };

    defaultGateway6 = {
      address = "fe80::1";
      interface = "eno1";
    };
  };
}
