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
      direnv
      fastfetch
      gcc
      glow
      gnupg
      gnutls
      gojq
      gomplate
      gopass
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
      # ratarmount
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

  services = {
    syncthing = {
      enable = true;
    };
  };
  xdg.configFile = {
    "htop/htoprc".source = ./htop/htoprc;
  };
}
