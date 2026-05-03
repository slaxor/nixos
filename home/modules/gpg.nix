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
}
