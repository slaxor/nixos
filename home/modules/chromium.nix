{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    # ungoogled-chromium
    # gopass
    # gopass-summon-provider
    # gopass-jsonapi
  ];

  programs.chromium = {
    enable = true;
    # package = pkgs.ungoogled-chromium;
    commandLineArgs = [
      "--no-default-browser-check"
    ];
    # nativeMessagingHosts = [ pkgs.keepassxc ];
    extensions = [
      # { id = "kkhfnlkhiapbiehimabddjbimfaijdhk"; } # gopass bridge
      { id = "oboonakemofpalcgghocfoadofidjkkk"; } # keepassxc-browser
    ];
  };

  # systemd.user.tmpfiles.rules = [
  # "C %h/.config/chromium/NativeMessagingHosts/com.justwatch.gopass.json - - - - ${
  # pkgs.writeText "gopass-manifest.json" (
  # builtins.toJSON {
  # name = "com.justwatch.gopass";
  # description = "Gopass wrapper to search and return passwords";
  # path = "${config.xdg.configHome}/gopass/gopass_wrapper.sh";
  # type = "stdio";
  # allowed_origins = [ "chrome-extension://kkhfnlkhiapbiehimabddjbimfaijdhk/" ];
  # }
  # )
  # }"
  # ];
  # xdg.configFile."chromium/NativeMessagingHosts/com.justwatch.gopass.json" = {
  # text = builtins.toJSON {
  # name = "com.justwatch.gopass";
  # description = "Gopass wrapper to search and return passwords";
  # path = "${config.xdg.configHome}/gopass/gopass_wrapper.sh";
  # type = "stdio";
  # allowed_origins = [ "chrome-extension://kkhfnlkhiapbiehimabddjbimfaijdhk/" ];
  # };
  # };
}
