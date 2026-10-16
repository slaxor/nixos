{ pkgs, ... }:
let
  wgDebug = pkgs.writeShellApplication {
    name = "wg-debug";
    runtimeInputs = [
      pkgs.iproute2
      pkgs.wireguard-tools
    ];
    text = builtins.readFile ./wg-debug.sh;
  };
in
{
  environment.systemPackages = with pkgs; [
    wgDebug
    bcc
    bpftools
    bpftrace
    wireguard-tools
    wg-netmanager
    dig
    djbdns
    dnsdiag
    dnsperf
    tcping-go
    tcpdump
    tcptraceroute
    tcpcrypt
    nmap
    socat
    netcat-gnu
    dbd
    snicat
    whois
  ];

  systemd.network.wait-online.anyInterface = true;

  boot.specialFileSystems."/sys/fs/bpf" = {
    device = "bpffs";
    fsType = "bpf";
  };

  programs = {
    ssh = {
      startAgent = true;
      enableAskPassword = true;
    };
  };

  services = {
    openssh = {
      enable = true;
      settings.KbdInteractiveAuthentication = false;
    };
  };
}
