# this is currently just a bag of dogfood I don't yet know what to do with
{ pkgs, ... }:
{
  home.packages =
    with pkgs;
    [
      alsa-utils
      archivemount
      aspell
      aspellDicts.de
      aspellDicts.en
      bsdgames
      bubblewrap
      direnv
      fastfetch
      gcc
      glow
      gnupg
      gnutls
      gojq
      gomplate
      graphviz-nox
      htop
      imagemagick
      jq
      just
      libqalculate
      libressl
      lilypond
      mermaid-cli
      miller # data manipulation for csv,json etc.
      nh
      nix-your-shell
      nixos-anywhere
      nixos-generators
      nmap
      nmap-formatter
      pgcli
      picocom
      pkg-config
      pulseaudioFull
      qrencode
      rclone
      rtl-sdr
      dump1090-fa
      soapysdr-with-plugins
      signal-cli
      tcpdump
      tcpflow
      tcping-rs
      tcpreplay
      tcptraceroute
      timidity
      tinymist
      tmux
      trash-cli
      typst
      udev
      udiskie
      unzip
      usbutils
      yq
      zoxide
    ]
    ++ (with typstPackages; [
      zebraw
    ]);

  programs = {
    bash.enable = true;
    fzf.enable = true;
    home-manager.enable = true;
    ssh.enable = true;

    zoxide = {
      enable = true;
      enableBashIntegration = true;
    };
  };

  home = {
    sessionVariables = {
      LESS_TERMCAP_mb = "$(tput bold; tput setaf 2)";
      LESS_TERMCAP_md = "$(tput bold; tput setaf 6)";
      LESS_TERMCAP_me = "$(tput sgr0)";
      LESS_TERMCAP_so = "$(tput bold; tput setaf 3; tput setab 4)";
      LESS_TERMCAP_se = "$(tput rmso; tput sgr0)";
      LESS_TERMCAP_us = "$(tput smul; tput bold; tput setaf 7)";
      LESS_TERMCAP_ue = "$(tput rmul; tput sgr0)";
      LESS_TERMCAP_mr = "$(tput rev)";
      LESS_TERMCAP_mh = "$(tput dim)";
      LESS_TERMCAP_ZN = "$(tput ssubm)";
      LESS_TERMCAP_ZV = "$(tput rsubm)";
      LESS_TERMCAP_ZO = "$(tput ssupm)";
      LESS_TERMCAP_ZW = "$(tput rsupm)";
      SSH_ASKPASS_REQUIRE = "prefer";
      SSH_ASKPASS = "wayprompt-ssh-askpass";
      SYSTEMD_PAGER = "cat";
    };
  };

  xdg.configFile = {
    "htop/htoprc".source = ./htop/htoprc;
  };
}
