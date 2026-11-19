{ pkgs, ... }:
let
  sender = "borg@hare.m11s.de";
  recipient = "sascha.teske@microprojects.de";
  recipientDomain = "microprojects.de";
  sourceIp = "144.76.195.142";
in
{
  systemd.services."notify-failure@" = {
    description = "Mail the journal of failed unit %i";
    serviceConfig.Type = "oneshot";
    scriptArgs = "%i";
    path = [
      pkgs.coreutils
      pkgs.dig
      pkgs.gnused
      pkgs.msmtp
      pkgs.systemd
    ];
    script = ''
      unit=$1

      lookup() { dig +short "$@" | sort -n | head -n 1 | sed 's/^[0-9]* //; s/\.$//'; }
      mx=$(lookup mx ${recipientDomain})
      helo=$(lookup -x ${sourceIp})
      [ -n "$mx" ] || { echo "no MX for ${recipientDomain}" >&2; exit 1; }
      [ -n "$helo" ] || { echo "no PTR for ${sourceIp}" >&2; exit 1; }

      {
        printf 'From: hare <${sender}>\n'
        printf 'To: ${recipient}\n'
        printf 'Date: %s\n' "$(date -R)"
        printf 'Subject: [hare] %s failed\n\n' "$unit"
        journalctl --unit "$unit" --boot --lines 60 --no-pager
      } | msmtp --host="$mx" --port=25 --auth=off \
            --tls=on --tls-starttls=on \
            --source-ip=${sourceIp} --domain="$helo" \
            --from=${sender} ${recipient}
    '';
  };
}
