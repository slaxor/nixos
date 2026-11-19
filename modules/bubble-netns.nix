{ inputs, pkgs, ... }:
let
  hare = import ../hosts/hare/address.nix;
  sealVm = pkgs.writeText "bubble-seal.nft" ''
    table inet bubble {
      chain forward {
        type filter hook forward priority 0; policy accept;
        iifname "lan" ct state new drop
      }
    }
  '';
  uplinkNat = pkgs.writeText "bubble-uplink.nft" ''
    table ip bubble-uplink {
      chain postrouting {
        type nat hook postrouting priority srcnat;
        ip saddr 10.66.0.2 oifname != "bubble-kea" masquerade
      }
    }
  '';
in
{
  environment.systemPackages = [
    (pkgs.callPackage ../pkgs/bubble {
      flake = inputs.self;
      mirror = "/data/backup/borg-hare";
    })
  ];

  networking.networkmanager.unmanaged = [
    "br-bubble"
    "bubble-lan"
    "bubble-kea"
  ];

  environment.etc."netns/bubble/resolv.conf".text = ''
    nameserver 9.9.9.9
  '';

  environment.etc."bubble/bashrc".text = ''
    [ -f ~/.bashrc ] && . ~/.bashrc
    PS1="(bubble) $PS1"
  '';

  systemd.services.bubble-netns = {
    description = "Network namespace impersonating hare's /27 for the restore drill";
    path = [
      pkgs.iproute2
      pkgs.nftables
      pkgs.procps
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ip netns add bubble
      ip -n bubble link set lo up

      ip link add br-bubble type bridge forward_delay 0
      ip link set br-bubble up

      ip link add bubble-lan type veth peer name lan netns bubble
      ip link set bubble-lan master br-bubble up
      ip -n bubble addr add ${hare.ipv4.gateway}/${toString hare.ipv4.prefixLength} dev lan
      ip -n bubble link set lan up

      ip link add bubble-kea type veth peer name kea netns bubble
      ip addr add 10.66.0.1/30 dev bubble-kea
      ip link set bubble-kea up
      ip -n bubble addr add 10.66.0.2/30 dev kea
      ip -n bubble link set kea up
      ip -n bubble route add default via 10.66.0.1

      sysctl -qw net.ipv4.ip_forward=1
      ip netns exec bubble sysctl -qw net.ipv4.ip_forward=1
      ip netns exec bubble nft -f ${sealVm}
      nft -f ${uplinkNat}
    '';
    preStop = ''
      nft delete table ip bubble-uplink
      ip link del bubble-kea
      ip link del bubble-lan
      ip netns del bubble
      ip link del br-bubble
    '';
  };

  systemd.services.bubble-dhcp = {
    description = "DHCP for hare-bubble inside the bubble namespace";
    bindsTo = [ "bubble-netns.service" ];
    after = [ "bubble-netns.service" ];
    serviceConfig = {
      NetworkNamespacePath = "/run/netns/bubble";
      ExecStart = toString [
        "${pkgs.dnsmasq}/bin/dnsmasq"
        "--keep-in-foreground"
        "--no-resolv"
        "--port=0"
        "--interface=lan"
        "--bind-interfaces"
        "--dhcp-authoritative"
        "--dhcp-ignore-clid"
        "--dhcp-range=${hare.ipv4.address},static"
        "--dhcp-host=52:54:00:00:01:42,${hare.ipv4.address}"
        "--dhcp-leasefile=/run/bubble-dhcp.leases"
      ];
    };
  };
}
