{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    librewolf
    gopass-jsonapi
    (pkgs.writeShellScriptBin "librewolf-limited" ''
      exec systemd-run --user --scope -p CPUQuota=200% librewolf "$@"
    '')
  ];

  programs = {
    librewolf = {
      enable = true;
      settings = {
        "webgl.disabled" = false;
        # "privacy.resistFingerprinting" = false;
        # "privacy.clearOnShutdown.history" = false;
        # "privacy.clearOnShutdown.cookies" = false;
        # "network.cookie.lifetimePolicy" = 0;
        "gfx.webrender.all" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        "media.hardware-video-decoding.force-enabled" = true;
      };
    };
  };
  xdg = {
    enable = true;
    desktopEntries = {
      librewolf = {
        name = "librewolf";
        exec = "librewolf-limited %U";
        icon = "librewolf";
        terminal = false;
        categories = [
          "Network"
          "WebBrowser"
        ];
        mimeType = [
          "text/html"
          "text/xml"
          "application/xhtml+xml"
          "x-scheme-handler/http"
          "x-scheme-handler/https"
        ];
      };
    };
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "librewolf.desktop";
        "x-scheme-handler/about" = "librewolf.desktop";
        "x-scheme-handler/http" = "librewolf.desktop";
        "x-scheme-handler/https" = "librewolf.desktop";
        "x-scheme-handler/unknown" = "librewolf.desktop";
      };
    };
  };

  home.file.".mozilla/native-messaging-hosts/com.justwatch.gopass.json" = {
    text = builtins.toJSON {
      name = "com.justwatch.gopass";
      description = "Gopass wrapper to search and return passwords";
      path = "${config.xdg.configHome}/gopass/gopass_wrapper.sh";
      type = "stdio";
      allowed_extensions = [
        "{eec37db0-22ad-4bf1-9068-5ae08df8c7e9}"
      ];
    };
  };
}
