{
  networking = {
    firewall.enable = false; # disable the iptables-based firewall
    nftables = {
      enable = true;
      ruleset = ''
        table inet filter {
          chain input {
            type filter hook input priority 0; policy drop;
            ct state established,related accept
            iifname "lo" accept
            iifname "wg0" accept
            iifname "cilium_*" accept
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
            icmp type echo-request accept
            ip protocol icmp accept
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

    nameservers = [ "127.0.0.1" ];

    wireguard.interfaces.wg0 = {
      ips = [ "10.13.0.1/24" ];
      listenPort = 51820;
      privateKeyFile = "/etc/wireguard/privatekey";
      postSetup = "ip link set wg0 txqueuelen 5000";

      peers = [
        # slash@kea
        {
          presharedKeyFile = "/etc/wireguard/slash@kea.psk";
          publicKey = "Ah8uUMZI5pbrHmn2D2l74G2IW3hcjtEWXtRFXebMLDg=";
          allowedIPs = [ "10.13.0.16/28" ];
        }
        # thorsten
        {
          presharedKeyFile = "/etc/wireguard/thorsten@kail.psk";
          publicKey = "GSRGgehbiBvDTcm5R9ryXr78Mz3JSOqsYHSsuCgnjB4=";
          allowedIPs = [ "10.13.0.32/28" ];
        }
        # ming
        {
          presharedKeyFile = "/etc/wireguard/ming@home.psk";
          publicKey = "X4Jy7bzRMz64xEL1bAqdlv9Lc//NKxJZ+sbW7W+Spg4=";
          allowedIPs = [ "10.13.0.48/28" ];
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
