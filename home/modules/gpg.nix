{
  pkgs,
  ...
}:
let
  pinentry-switch = pkgs.writeShellScriptBin "pinentry" ''
    case "$PINENTRY_USER_DATA" in
    *curses*)
      exec ${pkgs.pinentry-curses}/bin/pinentry-curses "$@"
      ;;
    esac
    exec ${pkgs.pinentry-qt}/bin/pinentry-qt "$@"
  '';
in
{
  home.packages = with pkgs; [
    gnupg
  ];

  programs = {
    gpg = {
      enable = true;
      mutableKeys = true;
      mutableTrust = true;
    };

    bash.initExtra = ''
      export PINENTRY_USER_DATA=curses
    '';
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableBashIntegration = true;

    defaultCacheTtl = 28800;
    maxCacheTtl = 28800;
    defaultCacheTtlSsh = 28800;
    maxCacheTtlSsh = 28800;
    pinentry.package = pinentry-switch;
  };

}
