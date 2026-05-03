{ pkgs, ... }:
{
  home.packages = with pkgs; [
    aspell
    aspellDicts.de
    aspellDicts.en
    gnupg
    gnutls
    isync # for mbsync
    khal
    khard
    mutt
    notmuch
    tmux
    unzip
  ];

  programs = {
    mbsync.enable = true;
  };
}
