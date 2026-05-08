{
  config,
  pkgs,
  lib,
  ...
}:

{
  home.packages = with pkgs; [
    gnupg
    gopass
    wayprompt
    pinentry-curses
  ];

  programs = {
    gpg = {
      enable = true;
      mutableKeys = true;
      mutableTrust = true;
    };
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableBashIntegration = true;

    defaultCacheTtl = 28800;
    maxCacheTtl = 28800;
    defaultCacheTtlSsh = 28800;
    maxCacheTtlSsh = 28800;
    pinentry.package = lib.mkDefault pkgs.pinentry-curses;
  };

  home = {
    shellAliases = {
      boott5l = "while ! $(ping -4 -W 1 -c 1 hare.t5l.de >/dev/null 2>&1 ) ; do echo down ; done ; gopass show -f luks/hare |ssh hareboot cryptsetup-askpass";
      pwc = "gopass ls --flat | fzf | xargs --no-run-if-empty gopass show -c";
    };
  };

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
