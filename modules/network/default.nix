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

  wgPeers = pkgs.writeShellApplication {
    name = "wg-peers";
    runtimeInputs = [
      pkgs.wireguard-tools
      pkgs.iproute2
      pkgs.python3
      pkgs.qrencode
    ];
    text = builtins.readFile ./wg-peers.sh;
  };
in
{
  # Interessanter link:
  # https://www.monotux.tech/posts/2024/02/nixos-system-config/
  # { config, lib, ... }:
  # let
  # secretsFile = "/var/lib/dnsmasq/secrets.conf";
  # gen = builtins.fromJSON (builtins.readFile ../interfaces.json);
  # interfaces = lib.catAttrs "name" gen.interfaces;
  # dhcp-ranges = lib.catAttrs "dhcp-range" gen.interfaces;
  # domains = lib.catAttrs "domain" gen.interfaces;
  # domain_maps = builtins.map ({domain, subnet, ...}: "domain=${domain},${subnet}") gen.interfaces;
  # in
  environment.systemPackages = with pkgs; [
    wgDebug
    wgPeers
    bcc
    bpftools
    bpftrace
    wireguard-tools
    wg-netmanager
    dig
    djbdns
    dnsdiag
    dnsperf
    dnsmon-go
    tcping-go
    nmap
    socat
    netcat-gnu
    dbd
    snicat
    whois
  ];

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

  # nginx = {
  # enable = true;
  # virtualHosts."developers.stackit.schwarz" = {
  # forceSSL = true;
  # sslCertificate = "/var/lib/local-pki/cert.pem";
  # sslCertificateKey = "/var/lib/local-pki/key.pem";
  # locations."/" = {
  # proxyPass = "http://127.0.0.1:3000";
  # proxyWebsockets = true;
  # };
  # };
}
