{ pkgs, lib, ... }:
let
  # --- shell scripts ---
  dnsup = pkgs.writeShellScriptBin "dnsup" ''
    add() {
      set -euo pipefail
      [[ $# -ne 2 ]] && { echo "usage: dnsup <hostname> <ip>"; exit 1; }
      echo "$2  $1" >> /var/lib/dnsmasq/local.hosts
    }

    del() {
      echo "$1 -> $2"
      [[ $# -ne 1 ]] && { echo "usage: dns-rm <hostname>"; exit 1; }
      sed -i "/ $1$/d" /var/lib/dnsmasq/local.hosts
      pkill -HUP dnsmasq
      echo "removed $1"
    }

    list() {
      cat /var/lib/dnsmasq/local.hosts
    }

    "$@"
  '';

  # --- adblock list sources ---
  adblockSources = [
    "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
    "https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt"
  ];

  updateAdblock = pkgs.writeShellScriptBin "dns-update-adblock" ''
    set -euo pipefail
    tmp=$(mktemp)
    trap "rm -f $tmp" EXIT

    ${lib.concatMapStringsSep "\n" (url: ''
      echo "fetching ${url}..."
      ${pkgs.curl}/bin/curl -sSfL "${url}" >> "$tmp" || echo "failed: ${url}"
    '') adblockSources}

    # normalise: strip comments, blank lines, localhost entries, convert to hosts format
    grep -E '^(0\.0\.0\.0|127\.0\.0\.1) ' "$tmp" \
      | grep -v '0\.0\.0\.0 0\.0\.0\.0' \
      | grep -v '127\.0\.0\.1 localhost' \
      | sed 's/^127\.0\.0\.1/0.0.0.0/' \
      | sort -u \
      > /var/lib/dnsmasq/adblock.hosts

    pkill -HUP dnsmasq
    echo "adblock: $(wc -l < /var/lib/dnsmasq/adblock.hosts) entries"
  '';

in
{
  environment.systemPackages = with pkgs; [
    dnsup
    updateAdblock
    dnsmasq
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
          "/var/lib/dnsmasq/adblock.hosts"
        ];
        dhcp-authoritative = true;
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
      ExecStart = "${updateAdblock}/bin/dns-update-adblock";
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
