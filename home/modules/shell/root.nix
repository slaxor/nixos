{ pkgs, ... }:

{
  home.packages = with pkgs; [
    aspell
    aspellDicts.de
    aspellDicts.en
    bats
    fzf
    gnutls
    gojq
    htop
    just
    mc
    nh
    nix-your-shell
    nixos-anywhere
    nixos-generators
    tmux
    trash-cli
    unzip
    usbutils
    zoxide
  ];

  home = {
    sessionVariables = {
      LESS = "--quit-if-one-screen";
      PROMPT_DIRTRIM = 2;
    };

    shellAliases = {
      hms = "home-manager switch --flake  $HOME/.config/home-manager#$USER";
      jq = "${pkgs.gojq}/bin/gojq";
      mc = "${pkgs.mc}/libexec/mc/mc-wrapper.sh";
      nors = "sudo nixos-rebuild switch --flake /etc/nixos#$HOSTNAME";
      za = "zoxide add \"$PWD\"";
      dmesg = "dmesg -HT";
      g = "rg --hidden --follow --smart-case";
      httpserver = "python3 -m http.server 8000 --bind 127.0.0.1";
      rmswp = "rm -vf ~/tmp/*.sw?";
      ownit = "sudo chown -R $USER:$GROUPS .";
      timestamp = "date +%Y%m%d%H%M%S";
      sslconn = "rlwrap -D2 openssl s_client -crlf -connect";
      fixtty = "stty sane ; echo -e \"\\033c\" ; tput rs1";
    };
  };

  programs = {
    bash = {
      enable = true;
      sessionVariables = {
        PS1 = ''\[\033[48;5;52;38;5;8m\]\[\e]0;\u@\h: \w\a\]\u@\h:\w#\[\033[0m \]'';
      };
      initExtra = ''
        shopt -s histverify
        shopt -s histappend # Append to the history file, don't overwrite it
        shopt -s globstar  # Enable recursive globbing with ** (e.g., ls **/*.go)
        shopt -s cdspell  # Correct minor spelling errors in cd commands
        export PROMPT_COMMAND="history -a; history -n; $PROMPT_COMMAND"
        if [ -d "''${HOME}/.bashrc.d" ];
        then
          for i in "''${HOME}/.bashrc.d"/*.sh
          do
            if [ -r "''${i}" ];
            then
              source "''${i}"
            fi
          done
          unset i
        fi
      '';
      historySize = 10000;
      historyFileSize = 10000;
      historyControl = [
        "ignoredups"
        "erasedups"
        "ignorespace"
      ];
    };

    fzf.enable = true;

    readline = {
      enable = true;
      extraConfig = ''
        set completion-ignore-case on
        set show-all-if-ambiguous on
      '';
    };

    zoxide = {
      enable = true;
      enableBashIntegration = true;
    };
  };

  home.file = {
    ".bashrc.d/60-fns.sh".source = ./.bashrc.d/60-fns.sh;
    ".xkb".source = ./.xkb;
  };

  xdg.configFile = {
    "mc/ini".source = ./mc/ini.root;
    "mc/panels.ini".source = ./mc/panels.ini;
  };
}
