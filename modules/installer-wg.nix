{
  config,
  lib,
  pkgs,
  ...
}:
let
  hub = import ../hosts/hare/wg-hub.nix;
  uki = config.boot.uki;

  wgiUp = pkgs.writeShellApplication {
    name = "wgi-up";
    runtimeInputs = with pkgs; [
      coreutils
      gnused
      iproute2
      wireguard-tools
    ];
    text = ''
      param() {
        tr ' ' '\n' </proc/cmdline | sed -n "s/^wgi\.$1=//p"
      }

      address=$(param address)
      if [ -z "$address" ]; then
        echo "no wgi.address on the kernel command line, staying offline" >&2
        exit 0
      fi

      install -d -m 700 /run/wgi
      param key >/run/wgi/key
      param psk >/run/wgi/psk

      [ -d /sys/class/net/wgi ] || ip link add wgi type wireguard
      wg set wgi \
        private-key /run/wgi/key \
        peer ${hub.publicKey} \
        preshared-key /run/wgi/psk \
        endpoint ${hub.endpoint} \
        allowed-ips ${hub.network} \
        persistent-keepalive 25
      ip address replace "$address" dev wgi
      ip link set wgi up
      ip route replace ${hub.network} dev wgi
    '';
  };

  mkInstallerEfi = pkgs.writeShellApplication {
    name = "mk-installer-efi";
    runtimeInputs = with pkgs; [
      coreutils
      gawk
    ];
    text = ''
      conf=''${1:?usage: mk-installer-efi <wg-peers client config> [output.efi]}
      out=''${2:-nixos-installer-$(basename "$conf" .conf).efi}

      field() {
        awk -v k="$1" '$1 == k { print $3; exit }' "$conf"
      }

      address=$(field Address)
      key=$(field PrivateKey)
      psk=$(field PresharedKey)
      for v in address key psk; do
        [ -n "''${!v}" ] || {
          echo "error: no $v in $conf" >&2
          exit 1
        }
      done

      ${pkgs.buildPackages.systemdUkify}/lib/systemd/ukify build \
        --config=${uki.configFile} \
        --cmdline="${uki.settings.UKI.Cmdline} wgi.address=$address wgi.key=$key wgi.psk=$psk" \
        --output="$out"
      ls -lh "$out"
    '';
  };
in
{
  hardware.enableRedistributableFirmware = lib.mkForce true;
  networking.networkmanager.enable = true;

  boot.uki.settings.UKI.Initrd = "${config.system.build.netbootRamdisk}/initrd";

  systemd.services.wgi = {
    description = "WireGuard tunnel to hare";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = 10;
      ExecStart = lib.getExe wgiUp;
    };
  };

  services.getty.helpLine = lib.mkForce ''

    Nothing to do here: Sascha connects to this computer remotely.
    Hier ist nichts zu tun: Sascha verbindet sich aus der Ferne.

    No network cable? Type nmtui and press Enter to pick a WiFi.
    Kein Netzwerkkabel? nmtui eingeben, Enter drücken und ein WLAN wählen.
  '';

  system.build.mkInstallerEfi = mkInstallerEfi;
}
