{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.local-pki;
in {
  options.services.local-pki = {
    enable = mkEnableOption "Local PKI with mkcert";
    domain = mkOption {
      type = types.str;
      default = "example.local";
      description = "The base domain for the wildcard-certifikate.";
    };

    certDir = mkOption {
      type = types.path;
      default = /var/lib/local-pki;
      description = "Path to store the certifikates.";
    };
  };

  config = mkIf cfg.enable {
    # Benötigte Pakete
    environment.systemPackages = [ pkgs.mkcert pkgs.nssTools ];

    systemd.services.local-pki-gen = {
      description = "Generates local TLS certifikates for ${cfg.domain}";
      wantedBy = [ "multi-user.target" ];
      before = [ "nginx.service" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        StateDirectory = "local-pki";
      };

      script = ''
        export CAROOT="${cfg.certDir}/ca"
        mkdir -p "$CAROOT"

        ${pkgs.mkcert}/bin/mkcert -install

        ${pkgs.mkcert}/bin/mkcert \
          -cert-file "${cfg.certDir}/cert.pem" \
          -key-file "${cfg.certDir}/key.pem" \
          "*.${cfg.domain}" "${cfg.domain}" "localhost" "127.0.0.1"

        chown -R root:nginx "${cfg.certDir}"
        chmod 750 "${cfg.certDir}"
        chmod 640 "${cfg.certDir}/key.pem"
      '';
    };

    security.pki.certificateFiles = lib.optional (builtins.pathExists "${cfg.certDir}/ca/rootCA.pem") "${cfg.certDir}/ca/rootCA.pem";

    services.dnsmasq = {
      enable = true;
      settings.address = "/.${cfg.domain}/127.0.0.1";
    };
    networking.networkmanager.dns = "dnsmasq";
  };
}
