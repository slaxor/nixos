{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.services.ipblock;
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

  updateIpblock = pkgs.writeShellScriptBin "ipblock-update" ''
    set -euo pipefail
    tmp=$(mktemp -d)
    trap "rm -rf $tmp" EXIT

    ${pkgs.curl}/bin/curl -sSfL \
      "https://raw.githubusercontent.com/Naunter/BT_BlockLists/master/bt_blocklists.gz" \
      | ${pkgs.gzip}/bin/gunzip \
      > "$tmp/raw.txt"

    grep -E '^[^#].*:[0-9]' "$tmp/raw.txt" \
      | cut -d: -f2- \
      | ${pkgs.python3}/bin/python3 ${range2cidr} \
      > /var/lib/ipblock/blocklist.cidr

    echo "ipblock-update: $(wc -l < /var/lib/ipblock/blocklist.cidr) CIDRs"
    # reload the live table if it's active
    if ${pkgs.nftables}/bin/nft list table inet ipblock &>/dev/null; then
      ipblock-load
    fi
  '';

  # builds an nft script from the current blocklist.cidr
  loadScript = pkgs.writeShellScriptBin "ipblock-load" ''
    set -euo pipefail
    cidr=/var/lib/ipblock/blocklist.cidr
    [[ -s $cidr ]] || { echo "no blocklist at $cidr"; exit 1; }
    elements=$(paste -sd, "$cidr")
    ${pkgs.nftables}/bin/nft -f - <<EOF
    table inet ipblock {
      set blackhole {
        type ipv4_addr
        flags interval
        auto-merge
        elements = { $elements }
      }
      chain input {
        type filter hook input priority -1; policy accept;
        ip saddr @blackhole drop
      }
      chain output {
        type filter hook output priority -1; policy accept;
        ip daddr @blackhole drop
      }
    }
    EOF
    echo "ipblock: loaded $(wc -l < $cidr) CIDRs"
  '';

  enableIpblock = pkgs.writeShellScriptBin "ipblock-enable" ''
    ipblock-load
  '';

  disableIpblock = pkgs.writeShellScriptBin "ipblock-disable" ''
    ${pkgs.nftables}/bin/nft delete table inet ipblock 2>/dev/null \
      && echo "ipblock: disabled" \
      || echo "ipblock: already inactive"
  '';

  statusIpblock = pkgs.writeShellScriptBin "ipblock-status" ''
    if ${pkgs.nftables}/bin/nft list table inet ipblock &>/dev/null; then
      count=$(${pkgs.nftables}/bin/nft list set inet ipblock blackhole \
        | grep -oP '\d+\.\d+\.\d+\.\d+[^,}]*' | wc -l)
      echo "ipblock: active ($count entries)"
    else
      echo "ipblock: inactive"
    fi
  '';

in
{
  options.services.ipblock = {
    enable = lib.mkEnableOption "IP blocklist via nftables" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      updateIpblock
      loadScript
      enableIpblock
      disableIpblock
      statusIpblock
    ];

    security.sudo.extraRules = [
      {
        commands =
          map
            (pkg: {
              command = "${pkg}/bin/${pkg.name}";
              options = [ "NOPASSWD" ];
            })
            [
              updateIpblock
              loadScript
              enableIpblock
              disableIpblock
              statusIpblock
            ];
        groups = [ "wheel" ];
      }
    ];

    systemd.tmpfiles.rules = [
      "d /var/lib/ipblock 0755 root root -"
      "f /var/lib/ipblock/blocklist.cidr 0644 root root -"
    ];

    systemd.services.ipblock = {
      description = "Load IP blocklist nftables table";
      after = [
        "network-online.target"
        "nftables.service"
      ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${loadScript}/bin/ipblock-load";
        ExecStop = "${disableIpblock}/bin/ipblock-disable";
      };
    };

    systemd.services.ipblock-update = {
      description = "Refresh IP blocklist";
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
  };
}
