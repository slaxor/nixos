{ pkgs, ... }:
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
{
  environment.systemPackages = with pkgs; [
    wireguard-tools
    wg-netmanager
    dnsmasq
    dig
    djbdns
    dnsdiag
    dnsperf
    tcping-go
  ];

  networking = {
    networkmanager = {
			enable = true;
			dns = "dnsmasq";
		};

    # nameservers = [
      # "1.1.1.1"
      # "8.8.8.8"
    # ];
    extraHosts = ''
      172.18.0.5 api.mgmt.sdc.runs.onstackit.local
      172.18.0.4 idp.mgmt.sdc.runs.onstackit.local
    '';
    firewall = {
      # allowedTCPPorts = [ 22 ];
      # allowedUDPPorts = [ ... ];
      enable = false;
    };
  };

  programs = {
    ssh = {
      startAgent = true;
      enableAskPassword = true;
    };
  };

  services = {
    # resolved.enable = true;
    dnsmasq = {
      enable = true;
      resolveLocalQueries = false;
      settings = {
        dhcp-authoritative = true;
        bind-interfaces = true;
        domain-needed = true;
        expand-hosts = true;
        bogus-priv = true;
        no-resolv = false;
        no-hosts = false;
        log-dhcp = true;
        no-poll = true;
        listen-address = "127.0.0.1";
        domain = "slaxor.local";
        server = [
          "8.8.4.4"
          "1.1.1.1"
        ];
        address = [
          "/loc/127.0.0.1"
          "/mgmt.sdc.runs.onstackit.local/127.0.0.1"
          "/idp.mgmt.sdc.runs.onstackit.local/172.18.0.4"
          "/api.mgmt.sdc.runs.onstackit.local/172.18.0.5"
          "/application.mgmt.sdc.runs.onstackit.local/172.18.0.6"
					"/developers.stackit.schwarz/127.0.0.1"
        ];
      };
    };

		nginx = {
			enable = true;
			virtualHosts."developers.stackit.schwarz" = {
				# forceSSL = true;
				# sslCertificate = "/var/lib/local-pki/cert.pem";
				# sslCertificateKey = "/var/lib/local-pki/key.pem";
				locations."/" = {
					proxyPass = "http://127.0.0.1:3000";
					proxyWebsockets = true;
				};
			};
		};

    openssh = {
      enable = true;
      settings.KbdInteractiveAuthentication = false;
    };
  };
}
