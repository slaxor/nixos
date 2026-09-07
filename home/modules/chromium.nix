{ pkgs, config, ... }:
{
  programs.chromium = {
    enable = true;
    package = pkgs.ungoogled-chromium;
    commandLineArgs = [
      "--no-default-browser-check"
      "--enable-features=UseOzonePlatform"
      "--ozone-platform=wayland"
      "--disable-pdf-extension"
    ];
    nativeMessagingHosts = [ pkgs.gopass ];
    extensions = [
      { id = "kkhfnlkhiapbiehimabddjbimfaijdhk"; } # gopass bridge
    ];
  };

}
