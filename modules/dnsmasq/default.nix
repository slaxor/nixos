{ pkgs, ... }:
let
  dnsup = pkgs.writeShellApplication {
    name = "dnsup";
    runtimeInputs = [
    ];
    text = builtins.readFile ./dnsup.sh;
  };

  updateAdblock = pkgs.writeShellApplication {
    name = "update-adblock";
    runtimeInputs = [
      pkgs.curl
    ];
    text = builtins.readFile ./update-adblock.sh;
  };

  devnet = pkgs.writeShellApplication {
    name = "devnet";
    runtimeInputs = [
      pkgs.dnsmasq
      pkgs.iproute2
      # pkgs.sudo
    ];
    text = builtins.readFile ./devnet.sh;
  };
in
{
  environment.systemPackages = with pkgs; [
    dnsup
    updateAdblock
    dnsmasq
    devnet
    atftp
    tftp-hpa
  ];

  networking.nameservers = [ "127.0.0.1" ];
  services = {
    openssh = {
      enable = true;
      settings.KbdInteractiveAuthentication = false;
    };
    resolved.enable = false;
    dnsmasq = {
      enable = true;
      resolveLocalQueries = false;
      settings = {
        server = [
          "8.8.4.4"
          "8.8.8.8"
          # "1.1.1.1"
          # "9.9.9.9"
        ];
        domain-needed = true;
        bogus-priv = true;
        cache-size = 1000;
        local = [ "/slax.lan/" ];
        addn-hosts = [
          "/var/lib/dnsmasq/local.hosts"
          # "/var/lib/dnsmasq/adblock.hosts"
        ];
        no-dhcp-interface = "*";
        dhcp-authoritative = false;
        bind-interfaces = true;
        expand-hosts = true;
        no-resolv = false;
        no-hosts = false;
        log-dhcp = true;
        no-poll = true;
        listen-address = "127.0.0.1";
        domain = "slaxor.local";
        address = [
          "/loc/127.0.0.1"
        ];
      };
    };
  };

  security.sudo.extraRules = [
    {
      commands =
        map
          (pkg: {
            command = "${pkg}/bin/${pkg.name}";
            options = [ "NOPASSWD" ];
          })
          [
            dnsup
            updateAdblock
          ];
      groups = [ "wheel" ];
    }
  ];

  systemd.tmpfiles.rules = [
    "f /var/lib/dnsmasq/local.hosts  0644 root root -"
    "f /var/lib/dnsmasq/adblock.hosts 0644 root root -"
  ];

  # fetch on boot and weekly thereafter
  systemd.services.dnsmasq-adblock = {
    description = "Update dnsmasq adblock lists";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${updateAdblock}/bin/update-adblock";
    };
  };

  systemd.timers.dnsmasq-adblock = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "2min";
      OnUnitActiveSec = "7d";
    };
  };
}
