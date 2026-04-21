{ pkgs, ... }:

let
  updateIpblock = pkgs.writeShellScriptBin "ipblock-update" ''
    set -euo pipefail
    tmp=$(mktemp -d)
    trap "rm -rf $tmp" EXIT
    out="$tmp/combined.txt"

    echo "fetching blocklists..."
    ${pkgs.curl}/bin/curl -sSfL \
      "https://raw.githubusercontent.com/Naunter/BT_BlockLists/master/bt_blocklists.gz" \
      | ${pkgs.gzip}/bin/gunzip \
      >> "$out"

    # format is "Description:startIP-endIP" — convert to CIDR
    grep -E '^[^#].*:[0-9]' "$out" \
      | cut -d: -f2- \
      | ${pkgs.python3}/bin/python3 ${range2cidr} \
      > /var/lib/ipblock/blocklist.cidr

    # atomic reload into ipset
    ${pkgs.ipset}/bin/ipset create blackhole-new hash:net \
      family inet hashsize 65536 maxelem 1000000
    while IFS= read -r cidr; do
      ${pkgs.ipset}/bin/ipset add blackhole-new "$cidr" 2>/dev/null || true
    done < /var/lib/ipblock/blocklist.cidr

    ${pkgs.ipset}/bin/ipset swap blackhole-new blackhole
    ${pkgs.ipset}/bin/ipset destroy blackhole-new

    echo "ipblock: $(wc -l < /var/lib/ipblock/blocklist.cidr) CIDRs loaded"
  '';

  # small python helper: range (1.2.3.4-1.2.3.99) -> CIDRs
  range2cidr = pkgs.writeText "range2cidr.py" ''
    import sys, ipaddress
    for line in sys.stdin:
        line = line.strip()
        if '-' not in line:
            continue
        try:
            start, end = line.split('-', 1)
            nets = ipaddress.summarize_address_range(
                ipaddress.IPv4Address(start.strip()),
                ipaddress.IPv4Address(end.strip())
            )
            for n in nets:
                print(n)
        except Exception:
            pass
  '';
in
{
  environment.systemPackages = [
    updateIpblock
    pkgs.ipset
  ];

  security.sudo.extraRules = [
    {
      commands = [
        {
          command = "${updateIpblock}/bin/ipblock-update";
          options = [ "NOPASSWD" ];
        }
      ];
      groups = [ "wheel" ];
    }
  ];

  systemd.tmpfiles.rules = [
    "d /var/lib/ipblock 0755 root root -"
    "f /var/lib/ipblock/blocklist.cidr 0644 root root -"
  ];

  systemd.services.ipblock-update = {
    description = "Update IP blocklist";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${updateIpblock}/bin/ipblock-update";
    };
  };

  systemd.timers.ipblock-update = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "3min";
      OnUnitActiveSec = "7d";
    };
  };

  # create the set on firewall start; rules reference it
  networking.firewall.extraCommands = ''
    ${pkgs.ipset}/bin/ipset create blackhole hash:net \
      family inet hashsize 65536 maxelem 1000000 2>/dev/null || true

    # load persisted list if available
    if [[ -s /var/lib/ipblock/blocklist.cidr ]]; then
      while IFS= read -r cidr; do
        ${pkgs.ipset}/bin/ipset add blackhole "$cidr" 2>/dev/null || true
      done < /var/lib/ipblock/blocklist.cidr
    fi

    iptables -I nixos-fw -m set --match-set blackhole src -j DROP
    iptables -I OUTPUT  -m set --match-set blackhole dst -j DROP
  '';

  networking.firewall.extraStopCommands = ''
    iptables -D nixos-fw -m set --match-set blackhole src -j DROP 2>/dev/null || true
    iptables -D OUTPUT   -m set --match-set blackhole dst -j DROP 2>/dev/null || true
  '';
}
