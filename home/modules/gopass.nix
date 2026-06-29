{ config, pkgs, ... }:
let
  gopassManifest = pkgs.writeText "com.justwatch.gopass.json" (
    builtins.toJSON {
      name = "com.justwatch.gopass";
      description = "Gopass wrapper to search and return passwords";
      path = "${config.xdg.configHome}/gopass/gopass_wrapper.sh";
      type = "stdio";
      allowed_extensions = [ "{eec37db0-22ad-4bf1-9068-5ae08df8c7e9}" ]; # gopass-bridge
    }
  );
in
{
  home = {
    shellAliases = {
      boott5l = "while ! $(ping -4 -W 1 -c 1 hare.t5l.de >/dev/null 2>&1 ) ; do echo down ; done ; gopass show -f luks/hare |ssh hareboot cryptsetup-askpass";
      pwc = "gopass ls --flat | fzf | xargs --no-run-if-empty gopass show -c";
    };
    file = {
      ".mozilla/native-messaging-hosts/com.justwatch.gopass.json" = {
        text = builtins.toJSON {
          name = "com.justwatch.gopass";
          description = "Gopass wrapper to search and return passwords";
          path = "${config.xdg.configHome}/gopass/gopass_wrapper.sh";
          type = "stdio";
          allowed_extensions = [
            "{eec37db0-22ad-4bf1-9068-5ae08df8c7e9}"
          ];
        };
      };
      ".mozilla/native-messaging-hosts/com.justwatch.gopass.json".source = gopassManifest;
    };
    packages = with pkgs; [
      gopass
    ];
  };

  programs.git.settings.credential.helper = "!gopass show git-creds $@";

  xdg.configFile."gopass/gopass_wrapper.sh" = {
    executable = true;
    text = ''
      #!/bin/sh
      export PATH="$PATH:$HOME/.nix-profile/bin" # required for Nix
      export GPG_TTY="$(tty)"
      export GOPASS_DEBUG_LOG=/tmp/gopass-jsonapi.log
      if [ -f ~/.gpg-agent-info ] && [ -n "$(pgrep gpg-agent)" ]; then
        source ~/.gpg-agent-info
        export GPG_AGENT_INFO
      else
        eval $(gpg-agent --daemon)
      fi
      export PATH="$PATH:/usr/local/bin"
      ${pkgs.gopass-jsonapi}/bin/gopass-jsonapi listen
      exit $?
    '';
  };
}
