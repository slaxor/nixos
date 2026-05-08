{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    # ungoogled-chromium
    gopass
    gopass-summon-provider
    gopass-jsonapi
  ];

  programs.chromium = {
    enable = true;
    # package = pkgs.ungoogled-chromium;
    # initialPrefs = {
    # "first_run_tabs" = [
    # "https://nixos.org/"
    # ];
    # };
    # homepageLocation = "";
    # defaultSearchProviderSuggestURL = "https://encrypted.google.com/complete/search?output=chrome&q={searchTerms}";
    # defaultSearchProviderSearchURL ="https://encrypted.google.com/search?q={searchTerms}&{google:RLZ}{google:originalQueryForSuggestion}{google:assistedQueryStats}{google:searchFieldtrialParameter}{google:searchClient}{google:sourceId}{google:instantExtendedEnabledParameter}ie={inputEncoding}";
    # extraOpts = {
    # "BrowserSignin" = 0;
    # "SyncDisabled" = true;
    # "PasswordManagerEnabled" = false;
    # "SpellcheckEnabled" = true;
    # "SpellcheckLanguage" = [
    # "de"
    # "en-US"
    # ];
    # };
    commandLineArgs = [
      "--no-default-browser-check"
    ];
    extensions = [
      "kkhfnlkhiapbiehimabddjbimfaijdhk" # gopass bridge
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
  xdg.configFile."chromium/NativeMessagingHosts/com.justwatch.gopass.json" = {
    text = builtins.toJSON {
      name = "com.justwatch.gopass";
      description = "Gopass wrapper to search and return passwords";
      path = "${config.xdg.configHome}/gopass/gopass_wrapper.sh";
      type = "stdio";
      allowed_origins = [ "chrome-extension://kkhfnlkhiapbiehimabddjbimfaijdhk/" ];
    };
  };
}
