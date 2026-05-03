{ pkgs, ... }:
{
  home.packages = with pkgs; [
    librewolf
    (pkgs.writeShellScriptBin "librewolf-limited" ''
      exec systemd-run --user --scope -p CPUQuota=200% librewolf "$@"
    '')
  ];

  programs = {
    librewolf = {
      enable = true;
      settings = {
        "gfx.webrender.all" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        "media.hardware-video-decoding.force-enabled" = true;
        # "privacy.resistFingerprinting" = false;
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
}
