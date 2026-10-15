{ pkgs, ... }:
let
  asciinema-scene = pkgs.python3Packages.buildPythonApplication rec {
    pname = "asciinema-scene";
    version = "1.2.3";
    pyproject = true;
    src = pkgs.fetchFromGitHub {
      owner = "jdum";
      repo = "asciinema-scene";
      rev = "v${version}";
      hash = "sha256-uDsDRaTFmW3476hRayz1Z0J+5Aleoyhl6Y08f/R8fQU=";
    };
    postPatch = ''
      cat > pyproject.toml << 'EOF'
      [build-system]
      requires = ["setuptools"]
      build-backend = "setuptools.build_meta"

      [project]
      name = "asciinema-scene"
      version = "1.2.3"

      [project.scripts]
      sciine = "asciinema_scene.sciine:cli"
      [tool.setuptools.packages.find]
      where = ["src"]
      EOF
    '';
    build-system = [ pkgs.python3Packages.setuptools ];
    dependencies = [ pkgs.python3Packages.click ];
    doCheck = false;
  };

  viewsqlite = pkgs.writeShellApplication {
    name = "viewsqlite";
    runtimeInputs = [
      pkgs.glow
      pkgs.sqlite
    ];
    text = builtins.readFile ./bin/viewsqlite.sh;
  };

  # which = pkgs.writeShellApplication {
  # name = "which";
  # runtimeInputs = [ pkgs.which ];
  # text = builtins.readFile ./bin/which.sh;
  # };
  which =
    (pkgs.writeShellApplication {
      name = "which";
      runtimeInputs = [ pkgs.which ];
      text = builtins.readFile ./bin/which.sh;
    }).overrideAttrs
      (old: {
        doInstallCheck = true;
        installCheckPhase = ''
          ${old.installCheckPhase or ""}
          PATH="$out/bin:$PATH" ${pkgs.bats}/bin/bats ${./bin/which-test.bats}
        '';
      });
  # ripdvd = pkgs.writeShellApplication {
  # name = "ripdvd";
  # runtimeInputs = [
  # pkgs.lsdvd
  # pkgs.handbrake
  # ];
  # text = builtins.readFile ./bin/ripdvd.sh;
  # };

  mkprj = pkgs.writeShellApplication {
    name = "mkprj";
    runtimeInputs = with pkgs; [
      nix
      git
      direnv
      jq
    ];
    text = builtins.readFile ./bin/mkprj.sh;
  };
in
{
  home.packages = with pkgs; [
    alsa-utils
    asciinema
    asciinema-scene
    asciiquarium-transparent
    aspell
    aspellDicts.de
    aspellDicts.en
    bash-language-server
    bash-language-server
    bashdb
    bat
    bats
    d2
    direnv
    direnv
    eza
    fastfetch
    fblog
    fzf
    glow
    gnutls
    gojq
    gurk-rs
    htop
    imagemagick
    just
    libqalculate
    lnav
    mermaid-cli
    mkprj
    moreutils
    mosquitto
    nh
    nix-direnv
    nix-your-shell
    nixos-anywhere
    nixos-generators
    nss_latest
    picocom
    rclone
    rich-cli
    # ripdvd
    screenkey
    shellcheck
    shfmt
    signal-cli
    timidity
    tmux
    trash-cli
    typst
    udiskie
    unzip
    usbutils
    viewsqlite
    vivid
    which
    zoxide
  ];

  home = {
    shellAliases = {
      dmesg = "sudo dmesg -HT";
      fixtty = "stty sane ; echo -e \"\\033c\" ; tput rs1";
      g = "rg --hidden --follow --smart-case";
      httpserver = "python3 -m http.server 8000 --bind 127.0.0.1";
      jq = "${pkgs.gojq}/bin/gojq";
      lsdesktop = "fd -e desktop . /run/current-system/sw/share/applications /etc/profiles/per-user/$(id -n -u)/share/applications ~/.nix-profile/share/applications";
      mc = "${pkgs.mc}/libexec/mc/mc-wrapper.sh";
      ns = "nix search nixpkgs";
      ownit = "sudo chown -R $USER:$GROUPS .";
      pwc = "gopass ls --flat | fzf | xargs --no-run-if-empty gopass show -c";
      qr = "qrencode -l L -t ANSI256UTF8";
      rmswp = "rm -vf ~/tmp/*.sw?";
      sslconn = "rlwrap -D2 openssl s_client -crlf -connect";
      timestamp = "date +%Y%m%d%H%M%S";
      yq = "${pkgs.gojq}/bin/gojq --yaml-input --yaml-output";
      za = "zoxide add \"$PWD\"";
      hareboot = ''
        ssh hareboot 'systemd-tty-ask-password-agent' \
                < <(gopass show -f luks/hare | awk 'NR==1{for(i=0;i<3;i++) print}')
      '';
      hm-repl = ''
        nix repl \
          --arg config "$(nix eval --raw .#nixosConfigurations.kea.config)" \
          --arg home-manager "$(nix eval --raw .#nixosConfigurations.kea.config.home-manager)" \
          --arg slash "$(nix eval --raw .#nixosConfigurations.kea.config.home-manager.users.slash)"\
      '';
      ncdu = ''
        ncdu --enable-shell --enable-delete --no-confirm-delete \
          --graph-style eighth-block -2 --show-itemcount --show-graph \
          --group-directories-first --delete-command "trash-put --" \
          -t 16'';
    };
  };

  programs = {
    bash = {
      enable = true;
      sessionVariables = {
        PS1 = ''\[\033[48;2;28;55;77m\]\[\033[38;2;40;85;119m\]\u@\h:\w\$\[\033[0m\] '';
        PS4 = "  ";
        PROMPT_DIRTRIM = 2;
      };

      initExtra = ''
        [[ $- == *i* ]] || return
        source ${./.bashrc.d/60-fns.sh}
        set-title() {
          printf "\033]0;%s@%s\007" "$USER" "$(hostname -s)"
        }

        npa() { nix profile add nixpkgs/nixos-unstable#$1 ; }

        s3mount() {
          local bucket="''${1:?Usage: s3mount <bucket> <mountpoint> [profile]}"
          local mountpoint="''${2:?Usage: s3mount <bucket> <mountpoint> [profile]}"
          local profile="''${3:-default}"
          mkdir -p "$mountpoint"
          s3fs "$bucket" "$mountpoint" \
            -o url=https://objs.m11s.de \
            -o use_path_request_style \
            -o profile="$profile" \
            -o endpoint=garage
        }
        PROMPT_COMMAND="set-title''${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
        shopt -s histverify
        shopt -s histappend # Append to the history file, don't overwrite it
        shopt -s globstar  # Enable recursive globbing with ** (e.g., ls **/*.go)
        shopt -s cdspell  # Correct minor spelling errors in cd commands
        # export PROMPT_COMMAND="history -a; history -n; $PROMPT_COMMAND"
        # if [ -d "''${HOME}/.bashrc.d" ];
        # then
          # for i in "''${HOME}/.bashrc.d"/*.sh
          # do
            # if [ -r "''${i}" ];
            # then
              # source "''${i}"
            # fi
          # done
          # unset i
        # fi
      '';
      historySize = 10000;
      historyFileSize = 10000;
      historyControl = [
        "ignoredups"
        "erasedups"
        "ignorespace"
      ];
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
      config.global.hide_env_diff = true;
    };

    fzf.enable = true;

    readline = {
      enable = true;
      extraConfig = ''
        # Make tab-completion case-insensitive
        set completion-ignore-case on

        # Show all possible completions on the first tab press
        set show-all-if-ambiguous on
      '';
    };

    zoxide = {
      enable = true;
      enableBashIntegration = true;
    };
  };

  # home.file = {
  # ".bashrc.d/60-fns.sh".source = ./.bashrc.d/60-fns.sh;
  # };

  xdg.configFile = {
    "mc/ini".source = ./mc/ini;
    "mc/panels.ini".source = ./mc/panels.ini;

    "glow/glow.yml".text = ''
      style: "tokyo-night"
      mouse: true
      pager: false
      tui: true
      width: 120
      all: false
      showlinenumbers: false
      preservenewlines: false
    '';

    "shellcheckrc".source = ./shellcheckrc;

    "nix/repl/default.nix".text = ''
      { config ? (import ./. {}).nixosConfigurations.kea.config
      , home-manager ? config.home-manager
      , slash ? home-manager.users.slash
      }:
      {
        _module.args = { inherit config home-manager slash; };
      }
    '';
  };
}
