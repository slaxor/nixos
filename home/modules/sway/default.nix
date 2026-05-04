{ pkgs, ... }:
let
  wpvol = pkgs.writeShellApplication {
    name = "wpvol";
    runtimeInputs = [
      pkgs.wireplumber
      pkgs.libnotify
      pkgs.coreutils
    ];
    text = builtins.readFile ./bin/wpvol;
  };
in
{

  imports = [
    ./librewolf.nix
  ];
  home.packages = with pkgs; [
    gvfs
    file-roller
    abaddon
    amberol
    avidemux
    bleachbit
    blueman
    brightnessctl
    clipcat
    deskflow
    dex
    discord
    evince
    fastfetch
    feh
    ffmpeg_6-full
    foliate
    foot.themes
    freeplane
    fuzzel
    glib
    gmrun
    gnomeExtensions.appindicator
    gopass-jsonapi
    gqrx
    grim
    gvfs
    halloy
    handbrake
    kdePackages.okular
    inkscape
    libappindicator
    libnotify
    localsend
    mako
    meld
    neovide
    networkmanagerapplet
    obs-studio
    obs-studio-plugins.advanced-scene-switcher
    obs-studio-plugins.input-overlay
    obs-studio-plugins.obs-3d-effect
    obs-studio-plugins.obs-shaderfilter
    obs-studio-plugins.wlrobs
    poppler-utils
    pulseaudioFull
    pwvucontrol
    qalculate-qt
    qrencode
    remmina
    rofi
    scrcpy
    seahorse
    signal-desktop
    slurp
    solaar
    spice-vdagent
    swappy
    sway
    swaybg
    swayimg
    transmission_4-gtk
    tray-tui
    tuba
    unclutter
    virt-manager
    virt-viewer
    virtualgl
    visidata
    vlc
    wallust
    way-displays
    waybar
    wayprompt
    wayvnc
    welle-io
    wl-clipboard
    wlay
    wlogout
    wluma
    wlvncc
    wpvol
    wttrbar
    wtype
    wvkbd
    xfce.thunar
    xfce.thunar-archive-plugin
    xfce.thunar-bare
    xfce.thunar-media-tags-plugin
    xfce.thunar-vcs-plugin
    xfce.thunar-volman
    xorg.xhost
    xournalpp
    xsettingsd
    zbar
    zeal
  ];

  home = {
    sessionVariables = {
      GIO_MODULE_DIR = "${pkgs.glib-networking}/lib/gio/modules/";
      GIO_USE_TLS = "gnutls";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      QT_QPA_PLATFORM = "wayland";
      QT_SCALE_FACTOR = "1.0";
      NIXOS_OZONE_WL = "1";
    };

    pointerCursor = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
      x11 = {
        enable = true;
        defaultCursor = "Adwaita";
      };
    };
  };
  programs = {
    feh = {
      themes = {
        booth = [
          "--full-screen"
          "--hide-pointer"
          "--slideshow-delay"
          "20"
        ];
        example = [
          "--info"
          "foo bar"
        ];
        feh = [
          "--image-bg"
          "black"
        ];
        imagemap = [
          "-rVq"
          "--thumb-width"
          "40"
          "--thumb-height"
          "30"
          "--index-info"
          "%n\\n%wx%h"
        ];
        present = [
          "--full-screen"
          "--sort"
          "name"
          "--hide-pointer"
        ];
        webcam = [
          "--multiwindow"
          "--reload"
          "20"
        ];
      };
    };

    firefox = {
      enable = true;
      profiles.your-profile-name = {
        settings = {
          "browser.shell.checkDefaultBrowser" = false;
        };
      };
      # Alternatively, via policies (global for all Firefox profiles)
      policies = {
        DontCheckDefaultBrowser = true;
      };
    };

    foot = {
      enable = true;
      server.enable = true;
      settings = {
        main = {
          include = [
            "${pkgs.foot.themes}/share/foot/themes/srcery" # starlight,
          ];
          dpi-aware = "yes";
          font = "FiraCode Nerd Font Mono Light:size=12";
          line-height = 12;
        };
        scrollback = {
          lines = 100000;
        };
      };
    };

    swaylock = {
      enable = true;
      package = pkgs.swaylock-effects;
      settings = {
        font = "pango:Iosevka Nerd Font Propo Medium 12";
        image = "~/.config/sway/background.jpg";
        effect-blur = "7x5";
        effect-vignette = "0.5:0.5";
        indicator-radius = 150;
        indicator-thickness = 15;
        ring-color = "79807288";
        inside-color = "00000088";
        line-color = "00000088";
        text-color = "CFE8D888";
        key-hl-color = "E0C47E88";
        inside-clear-color = "00700088";
        inside-ver-color = "00007088";
        inside-wrong-color = "70000088";
        ring-clear-color = "729BB588";
        ring-ver-color = "82AA7788";
        ring-wrong-color = "E57E7E88";
        text-clear-color = "729BB588";
        text-ver-color = "82AA7788";
        text-wrong-color = "E57E7E88";
      };
    };

    waybar = {
      enable = true;
      systemd.enable = true;
    };
  };

  services = {
    # wl-clip-persist = true;
    mako = {
      enable = true;
      settings = {
        ignore-timeout = true;
        default-timeout = 2000;
        layer = "overlay";
        anchor = "top-right";
        font = "Iosevka Nerd Font Propo Medium";
        border-radius = 2;
        background-color = "#202020d0";
        border-color = "#00000000";
        "urgency=low" = {
          border-color = "#808080d0";
          background-color = "#202020d0";
          text-color = "#808080d0";
          default-timeout = 2000;
        };
        "urgency=normal" = {
          border-color = "#4c78bcd0";
          background-color = "#4c78bcd0";
          text-color = "#ffffffd0";
          default-timeout = 2000;
        };
        "urgency=high" = {
          border-color = "#e54b4bd0";
          background-color = "#e54b4bd0";
          text-color = "#ffffffD0";
          default-timeout = 10000;
        };
        "mode=do-not-disturb" = {
          invisible = 1;
        };
        "app-name=notify-send.*Bluetooth" = {
          invisible = 1;
        };
      };
    };

    clipcat = {
      enable = true;
      menuSettings = {
        finder = "fuzzel";
      };
    };

    gnome-keyring.enable = true;

    gpg-agent.pinentry.package = pkgs.wayprompt;

    udiskie.enable = true;

    swayidle =
      let
        lock = "${pkgs.swaylock-effects}/bin/swaylock --daemonize";
        display = status: "swaymsg 'output * power ${status}'";
      in
      {
        enable = true;
        timeouts = [
          {
            timeout = 595;
            command = "${pkgs.libnotify}/bin/notify-send 'Locking in 5 seconds' -t 5000";
          }
          {
            timeout = 600;
            command = lock;
          }
          {
            timeout = 120;
            command = display "off";
            resumeCommand = display "on";
          }
          {
            timeout = 3600;
            command = "${pkgs.systemd}/bin/systemctl suspend";
          }
        ];
        events = [
          {
            event = "before-sleep";
            command = (display "off") + "; " + lock;
          }
          {
            event = "after-resume";
            command = display "on";
          }
          {
            event = "lock";
            command = (display "off") + "; " + lock;
          }
          {
            event = "unlock";
            command = display "on";
          }
        ];
      };
  };

  wayland.windowManager.sway = {
    wrapperFeatures.gtk = true;
    systemd.variables = [ "--all" ];
    config = {
      output = {
        "eDP-1" = {
          scale = "2.0";
        };
        "*" = {
          scale = "2.0";
          bg = "background.img";
          # fill";
        };
        "HDMI-A-1" = {
          scale = "1.0";
        };
      };
      modifier = "Mod4";
      terminal = "foot";
      startup = [
        { command = "librewolf"; }
        {
          command = "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway";
        }
      ];
    };
  };

  xdg = {
    enable = true;
    portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-wlr
        pkgs.xdg-desktop-portal-gtk
      ];
      # config.common.default = "*";
      config = {
        common = {
          default = [
            "wlr"
            "gtk"
          ];
          "org.freedesktop.impl.portal.ScreenCast" = "wlr";
          "org.freedesktop.impl.portal.Screenshot" = "wlr";
        };
      };
    };
    configFile = {
      "sway/background.jpg".source = ./sway/pingu_oldschool_bg.jpg;
      "sway/config".source = ./sway/config;
      "sway/config.d".source = ./sway/config.d;
      "waybar".source = ./waybar;
      "gtk-3.0/settings.ini".text = ''
        [Settings]
        gtk-font-name = Noto Sans 12
        gtk-theme-name = Adwaita
        gtk-icon-theme-name = Adwaita
        gtk-cursor-theme-name = Adwaita
        gtk-cursor-theme-size = 48
        gtk-xft-dpi = 196608  # 196608 = 2.0 * 96 * 1024
      '';
      "gtk-4.0/settings.ini".text = ''
        [Settings]
        gtk-font-name = Noto Sans 12
        gtk-cursor-theme-size = 48
      '';
    };

    desktopEntries = {
      tokodon-handler = {
        name = "Tokodon URI Handler";
        exec = "${pkgs.writeShellScript "tokodon-handler" ''
          uri="$1"
          url=$(echo "$uri" | sed -E 's|tokodon://[a-z]+\?url=||; s|tokodon://||')
          url=$(python3 -c "import sys, urllib.parse; print(urllib.parse.unquote(sys.argv[1]))" "$url")
          exec xdg-open "$url"
        ''} %u";
        mimeType = [ "x-scheme-handler/tokodon" ];
        noDisplay = true;
      };
    };

    mimeApps = {
      enable = true;
      defaultApplications = {
        "application/pdf" = "org.kde.okular.desktop";
        "inode/directory" = "thunar.desktop";
        # "text/html" = "librewolf.desktop";
        "video/mp4" = "vlc.desktop";
        # "x-scheme-handler/about" = "librewolf.desktop";
        # "x-scheme-handler/http" = "librewolf.desktop";
        # "x-scheme-handler/https" = "librewolf.desktop";
        "x-scheme-handler/tokodon" = "tokodon-handler.desktop";
        # "x-scheme-handler/unknown" = "librewolf.desktop";
      };
    };
    # terminal-exec = "${pkgs.foot}/bin/foot";
  };
  home.file.".xkb".source = ./.xkb;
}
