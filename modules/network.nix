{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    wireguard-tools
    wg-netmanager
    dnsmasq
    dig
    djbdns
    dnsdiag
    dnsperf
  ];

  networking = {
    networkmanager.enable = true;
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
    resolved.enable = true;
    dnsmasq = {
      enable = true;
      settings = {
        dhcpAuthoritative = true;
        # dhcp-leasefile = "/var/lib/dnsmasq/dnsmasq.leases";
        # conf-file = optional cfg.resolveLocalQueries "/etc/dnsmasq-conf.conf";
        # resolv-file = optional cfg.resolveLocalQueries "/etc/dnsmasq-resolv.conf";
        # bind-interfaces = true;
        dnsUpdate = true;
        dnsUpdateInterval = "60";
        listenAddress = "127.0.0.1";
      };
    };
        # dhcp-range = [ "192.168.0.2,192.168.0.254" ];
        # 172.18.0.4 idp.mgmt.sdc.runs.onstackit.local
        # 172.18.0.5 api.mgmt.sdc.runs.onstackit.local
        # Optionally, configure a key for DNS update authentication (TSIG)
        # Uncomment these lines if you're using TSIG authentication
        # updateKeyName = "foo.mymachine.local";
        # updateKeyValue = "YOUR-BASE64-ENCODED-KEY-HERE";
      # settings = ''
        # Enable DNS updates
        # dhcp-authoritative
        # dns-update
        # dns-update-interval=60
        # listen-address=127.0.0.1

        # Optional: Configure the key for DNS update authentication (if needed)
        # update-key-name=foo.mymachine.local
        # update-key-value=YOUR-BASE64-ENCODED-KEY-HERE

        # Optionally configure static IP address mappings for specific hosts
        # address=/foo.mymachine.local/127.0.0.1
      # '';
      # };
    openssh = {
      enable = true;
      settings.KbdInteractiveAuthentication = false;
    };
  };
}
