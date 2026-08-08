{ pkgs, config, ... }:
{
  programs.chromium = {
    enable = true;
    package = pkgs.ungoogled-chromium;
    commandLineArgs = [
      "--no-default-browser-check"
      "--enable-features=UseOzonePlatform"
      "--ozone-platform=wayland"
    ];
    nativeMessagingHosts = [ pkgs.gopass ];
    extensions = [
      { id = "kkhfnlkhiapbiehimabddjbimfaijdhk"; } # gopass bridge
    ];
    plugins = {
      always_open_pdf_externally = true;
    };
  };

}
