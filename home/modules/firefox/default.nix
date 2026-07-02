{ config, pkgs, ... }:
let
  addons = pkgs.nur.repos.rycee.firefox-addons;

  # about:config hardening - the subset that actually matters
  hardenedSettings = {
    "accessibility.typeaheadfind" = false;
    "beacon.enabled" = false;
    "browser.contentblocking.report.lockwise.enabled" = false; # Lockwise password manager promo in protection report
    "browser.link.open_newwindow.restriction" = 0;
    "browser.messaging-system.whatsNewPanel.enabled" = false;
    "browser.ml.chat.enabled" = false;
    "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
    "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
    "browser.newtabpage.activity-stream.feeds.telemetry" = false;
    "browser.newtabpage.activity-stream.showSponsored" = false;
    "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
    "browser.newtabpage.activity-stream.telemetry" = false;
    "browser.newtabpage.enabled" = false;
    "browser.profiles.enabled" = false; # kill new Selectable Profile UI - breaks profiles.ini-based setup
    "browser.search.suggest.enabled" = false;
    "browser.send_pings" = false;
    "browser.shell.checkDefaultBrowser" = false;
    "browser.shopping.experience2023.enabled" = false;
    "browser.startup.homepage" = "about:blank";
    "browser.startup.homepage_override.mstone" = "ignore";
    "browser.startup.page" = 0;
    "browser.translations.enable" = false;
    "browser.translations.automaticallyPopup" = false;
    "browser.urlbar.quicksuggest.enabled" = false;
    "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
    "browser.urlbar.suggest.quicksuggest.sponsored" = false;
    "browser.urlbar.suggest.searches" = false;
    "browser.vpn_promo.enabled" = false;
    "datareporting.healthreport.uploadEnabled" = false;
    "datareporting.policy.dataSubmissionEnabled" = false;
    "dom.event.clipboardevents.enabled" = false;
    "dom.disable_window_open_feature.menubar" = true;
    "dom.disable_window_open_feature.toolbar" = true;
    "dom.disable_window_open_feature.location" = true;
    "dom.disable_window_open_feature.personalbar" = true;
    "dom.disable_window_open_feature.status" = true;
    "dom.disable_window_open_feature.scrollbars" = true;
    "dom.disable_window_open_feature.resizable" = true;
    "extensions.autoDisableScopes" = 0;
    "extensions.pocket.enabled" = false; # already present, leaving for clarity
    "extensions.startupScanScopes" = 15;
    "extensions.webextensions.ExtensionStorageIDB.enabled" = false; # Fix foxy gestures?
    "geo.enabled" = false;
    "identity.fxaccounts.enabled" = true; # keep sync if you want it
    "identity.fxaccounts.toolbar.accessed" = true; # suppresses "new" badge nagging
    "media.ffmpeg.vaapi.enabled" = true;
    # "media.peerconnection.enabled" = false; # kills WebRTC IP leak
    "media.peerconnection.ice.default_address_only" = true;
    "media.peerconnection.ice.no_host" = true;
    # "network.cookie.cookieBehavior" = 1; # block 3rd-party cookies
    "network.cookie.cookieBehavior" = 4;
    "network.dns.disablePrefetch" = true;
    # "network.http.referer.XOriginPolicy" = 2;
    # "network.http.referer.XOriginTrimmingPolicy" = 2;
    "network.predictor.enabled" = false;
    "network.prefetch-next" = false;
    "privacy.donottrackheader.enabled" = true;

    "privacy.firstparty.isolate" = false;
    "privacy.resistFingerprinting" = false;
    "privacy.spoof_english" = 1;
    "privacy.trackingprotection.enabled" = false;
    "privacy.trackingprotection.socialtracking.enabled" = false;

    "signon.autofillForms" = false; # don't autofill stored logins
    "signon.firefoxRelay.feature" = "disabled";
    "signon.generation.enabled" = false; # no "suggest strong password" popups
    "signon.management.page.breach-alerts.enabled" = false; # no breach-monitor nags
    "signon.rememberSignons" = false; # no save-password prompt
    "toolkit.telemetry.enabled" = false;
    "toolkit.telemetry.unified" = false;
    "xpinstall.signatures.required" = false;
    "xpinstall.whitelist.required" = false;
  };

  # nix eval --raw .#nixosConfigurations.kea.pkgs.nur.repos.rycee.firefox-addons --apply 'a: builtins.concatStringsSep "\n" (builtins.attrNames a)'| grep -iE 'foxy|tabstash|tab-stash|umatrix|webdev|web-dev|download'
  fullExtensions = with addons; [
    consent-o-matic
    foxy-gestures
    gopass-bridge
    nuke-anything-enhanced
    tab-stash
    tampermonkey
    ublock-origin
    # umatrix
    web-developer
  ];

  workExtensions = with addons; [
    gopass-bridge
    ublock-origin
    foxy-gestures
  ];

  nuke-anything-enhanced = addons.buildFirefoxXpiAddon {
    pname = "nuke-anything-enhanced";
    version = "2.5resigned1"; # check AMO for current version
    addonId = "{1ced4832-f06e-413f-aa14-9eb63ad40ace}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4270259/nuke_anything_enhanced-2.5resigned1.xpi";
    sha256 = "sha256-xS+VhWSbqdV7I5HHQrkotFQPjGF7aLLiL/eOEEPqN5I=";
    meta = { };
  };

in
{
  programs.firefox = {
    enable = true;
    configPath = "${config.xdg.configHome}/mozilla/firefox";
    package = pkgs.firefox.overrideAttrs (old: {
      # hide the stock launcher; per-profile xdg.desktopEntries provide the visible ones
      postInstall = (old.postInstall or "") + ''
        desktop="$out/share/applications/firefox.desktop"
        if [ -f "$desktop" ]; then
          echo "NoDisplay=true" >> "$desktop"
        fi
      '';
    });
    profiles = {
      default = {
        id = 0;
        isDefault = true;
        settings = hardenedSettings;
        extensions.packages = fullExtensions;
      };

      work = {
        id = 1;
        settings = hardenedSettings;
        extensions.packages = workExtensions;
      };

      plain = {
        id = 2;
        # no settings, no extensions - as-is
      };

      # 3. Sandbox Profile is not to be used directly but copied to /tmp and called there
      # see
      sandbox = {
        id = 3;
        settings = hardenedSettings;
        extensions.packages = fullExtensions;
      };
    };
  };

  xdg = {
    desktopEntries = {
      firefox-default = {
        name = "Firefox (default)";
        genericName = "Web Browser";
        exec = "firefox -P default --no-remote %u";
        icon = "firefox";
        categories = [
          "Network"
          "WebBrowser"
        ];
        terminal = false;
      };
      firefox-work = {
        name = "Firefox (work)";
        genericName = "Web Browser";
        exec = "firefox -P work --no-remote %u";
        icon = "firefox";
        categories = [
          "Network"
          "WebBrowser"
        ];
        terminal = false;
      };
      firefox-plain = {
        name = "Firefox (plain)";
        genericName = "Web Browser";
        exec = "firefox -P plain --no-remote %u";
        icon = "firefox";
        categories = [
          "Network"
          "WebBrowser"
        ];
        terminal = false;
      };

      firefox-sandbox = {
        name = "Firefox (Sandbox)";
        genericName = "Web Browser";
        exec = "${pkgs.writeShellScript "firefox-sandbox" ''
          # 1. Create a fresh, unique directory in /tmp
          TMP_PROFILE=$(mktemp -d -p /tmp firefox-sandbox.XXXXXX)

          # 2. Locate where Nix actually wrote your declarative 'sandbox' profile
          NIX_PROFILE_SRC="${config.xdg.configHome}/mozilla/firefox/sandbox"

          echo "Syncing declarative configuration to sandbox..."
          if [ -d "$NIX_PROFILE_SRC" ]; then
            # Copy the user.js (settings) and extensions folder to /tmp
            mkdir -p "$TMP_PROFILE"
            cp -rL "$NIX_PROFILE_SRC/." "$TMP_PROFILE/"
          fi

          echo "Launching isolated sandbox in $TMP_PROFILE"
          # 3. Launch Firefox pointing to our temporary clone
          exec ${pkgs.firefox}/bin/firefox --profile "$TMP_PROFILE" --no-remote %u
        ''}";
        icon = "firefox";
        terminal = false;
        categories = [
          "Network"
          "WebBrowser"
        ];
      };
    };
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "firefox-default.desktop";
        "x-scheme-handler/http" = "firefox-default.desktop";
        "x-scheme-handler/https" = "firefox-default.desktop";
        "x-scheme-handler/about" = "firefox-default.desktop";
        "x-scheme-handler/unknown" = "firefox-default.desktop";
      };
    };
  };
}
