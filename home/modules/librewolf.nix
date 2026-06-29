{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    gopass-jsonapi
    (pkgs.writeShellScriptBin "librewolf-limited" ''
      exec systemd-run --user --scope -p CPUQuota=200% librewolf "$@"
    '')
  ];
  programs.librewolf = {
    enable = true;
    nativeMessagingHosts = [ pkgs.keepassxc ];
    profiles = {
      default = {
        isDefault = true;
        id = 0;
        settings = {
          "webgl.disabled" = false;
          # "privacy.resistFingerprinting" = false;
          # "privacy.clearOnShutdown.history" = false;
          # "privacy.clearOnShutdown.cookies" = false;
          # "network.cookie.lifetimePolicy" = 0;
          "gfx.webrender.all" = true;
          "media.ffmpeg.vaapi.enabled" = true;
          "media.hardware-video-decoding.force-enabled" = true;
          "browser.shell.checkDefaultBrowser" = false;
          "security.sandbox.content.level" = 4;
          "extensions.keepassxc-browser.enabled" = true;

        };
        extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
          keepassxc-browser

        ];
      };

      microprojects = {
        isDefault = false;
        id = 1;
        extensions = {
          packages = with pkgs.nur.repos.rycee.firefox-addons; [
            keepassxc-browser
          ];
        };
      };
    };
    policies = {
      DontCheckDefaultBrowser = true;
    };
  };

  programs.firefox = {
    configPath = "${config.xdg.configHome}/mozilla/firefox";
    enable = true;
    nativeMessagingHosts = [ pkgs.keepassxc ];
    profiles = {
      default = {
        isDefault = true;
        id = 0;
        settings = {
          "browser.shell.checkDefaultBrowser" = false;
        };
        extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
          # keepassxc-browser
          gopass
        ];
      };

      microprojects = {
        isDefault = false;
        id = 1;
        extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
          # keepassxc-browser
          gopass
        ];
      };
    };
    policies = {
      DontCheckDefaultBrowser = true;
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
