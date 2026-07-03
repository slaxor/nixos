{ pkgs, config, ... }:
let
  wgPeers = pkgs.writeShellApplication {
    name = "wg-peers";
    runtimeInputs = [
      pkgs.wireguard-tools
      pkgs.iproute2
      pkgs.gawk
      pkgs.qrencode
    ];
    text = builtins.readFile ./wg-peers.sh;
  };
in
{
  environment.systemPackages = [
    wgPeers
    pkgs.nftables
    pkgs.nftrace
  ];

  systemd.tmpfiles.rules = [
    "d /etc/wireguard/peers 0700 root root -"
  ];

  # sops: keep wg/key, drop the per-user psk secrets after migration
  sops.secrets."wg/key" = { };

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
            tcp dport { 25, 143 } accept
            tcp dport { 80, 443 } accept
            iifname "wg0" accept
            ip saddr 10.42.0.0/16 accept
            ip saddr 10.43.0.0/16 accept
            tcp dport { 6443, 12000 } drop
            icmp type echo-request accept
            ip protocol icmp accept
          }

          chain forward {
            type filter hook forward priority 0;
            iifname "wg0" oifname "wg0" accept
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
      privateKeyFile = config.sops.secrets."wg/key".path;
      postSetup = ''
        ip link set wg0 txqueuelen 5000
        ${wgPeers}/bin/wg-peers load
      '';
      peers = [ ];
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
