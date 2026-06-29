{
  config,
  pkgs,
  lib,
  ...
}:

{
  home.packages = with pkgs; [
    gnupg
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

}
