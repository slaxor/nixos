{ pkgs, lib, ... }:
let
  espansoPass = pkgs.writeShellApplication {
    name = "espanso-pass";
    runtimeInputs = [
      pkgs.gopass
      pkgs.gnugrep
      pkgs.gnused
      pkgs.coreutils
      pkgs.fuzzel
    ];
    text = builtins.readFile ./bin/espanso-pass.sh;
  };
in
{
  services.espanso = {
    enable = true;
    package = pkgs.espanso-wayland;
    configs.default.keyboard_layout.layout = "us";
    matches.base.matches = [
      {
        trigger = "@8<";
        replace = "-----------8<-----------8<-----------8<-----------8<-----------8<-----------";
      }
      {
        trigger = "@>8";
        replace = "----------->8----------->8----------->8----------->8----------->8-----------";
      }
      {
        trigger = "@stvat";
        replace = "DE20882888";
      }
      {
        trigger = "@st@g";
        replace = "sascha.teske@gmail.com";
      }
      {
        trigger = "@st@m";
        replace = "sascha.teske@microprojects.de";
      }
      {
        trigger = "@s@p";
        replace = "slaxor@posteo.de";
      }
      {
        trigger = "@gls";
        replace = ''
          Bankverbindung
          Kontoinhaber: Sascha Teske
          Bank: GLS Bank
          IBAN: DE33430609672019279100
          BIC: GENODEM1GLS
        '';
      }
      {
        trigger = "@ibangls";
        replace = "DE33430609672019279100";
      }
      {
        trigger = "@bicgls";
        replace = "GENODEM1GLS";
      }
      {
        trigger = "@mpadr";
        replace = ''
          Microprojects GmbH
          Beltgens Garten 5

          20537 Hamburg
        '';
      }
      {
        trigger = "@a@m";
        replace = "accounting@microprojects.de";
      }
      {
        trigger = "@mpvat";
        replace = "DE312932732";
      }
      {
        trigger = "@mpfoot";
        replace = ''
          =======================================================================
            Microprojects GmbH
            Geschäftsführer: Ingo Muhlack, Sascha Teske
            Anschrift: Beltgens Garten 5, 20537 Hamburg
            Telefon: +49 163 3922933
            email: info@microprojects.de
            URL: https://www.microprojects.de/
            Amtsgericht Hamburg Aktenzeichen: HRB 146987
            Steuernummer: 46/743/02466 USt-IdNr.: DE312932732
          =======================================================================
        '';
      }
      {
        trigger = "@grs";
        replace = ''
          Schöne Grüße
          Sascha Teske
        '';
      }
      {
        trigger = "@ts";
        replace = "{{timestamp}}";
        vars = [
          {
            name = "timestamp";
            type = "date";
            params.format = "%Y%m%d%H%M%S";
          }
        ];
      }
      {
        trigger = "@date";
        replace = "{{mydate}}";
        vars = [
          {
            name = "mydate";
            type = "date";
            params.format = "%d.%m.%Y";
          }
        ];
      }
      {
        regex = ":pw (?P<account>[\\w/.-]+) ?(?P<index>\\d*)@";
        replace = "{{pass}}!";
        vars = [
          {
            name = "pass";
            type = "shell";
            params.cmd = ''${lib.getExe espansoPass} "$ESPANSO_ACCOUNT" "$ESPANSO_INDEX"'';
          }
        ];
      }
    ];
  };

  wayland.windowManager.sway.config = {
    input = {
      "type:keyboard" = {
        xkb_layout = "us-german-umlaut";
      };
    };
    focus = {
      followMouse = false;
      mouseWarping = false;
    };
  };
}
