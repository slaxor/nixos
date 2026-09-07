{ fonts }:
{
  lib,
  pkgs,
  ...
}:
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
    gucharmap
    gvfs
    halloy
    kdePackages.okular
    inkscape
    libappindicator
    libnotify
    localsend
    mako
    meld
    neovide
    networkmanagerapplet
    pango
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
    swaybg
    swayimg
    transmission_4-gtk
    tray-tui
    tuba
    thunar-unwrapped
    thunar-archive-plugin
    thunar-media-tags-plugin
    thunar-vcs-plugin
    thunar-volman
    unclutter
    virt-manager
    virt-viewer
    virtualgl
    visidata
    vlc
    wallust
    way-displays
    waybar
    # waypipe
    # wayprompt
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
    xhost
    xournalpp
    xsettingsd
    zbar
    zeal
  ];

  gtk = {
    enable = true;
    font = {
      name = "${fonts.gui.name} ${fonts.gui.weight}";
      size = 12; # gtk font size is its own number, not your fonts.gui.size string
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    theme.name = "Adwaita";
    gtk3.extraConfig = {
      gtk-xft-dpi = 196608; # 2.0 * 96 * 1024
    };
  };

  home = {
    sessionVariables = {
      GIO_MODULE_DIR = "${pkgs.glib-networking}/lib/gio/modules/";
      GIO_USE_TLS = "gnutls";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      QT_QPA_PLATFORM = "wayland";
      QT_SCALE_FACTOR = "1.0";
      NIXOS_OZONE_WL = "1";
      WLR_NO_HARDWARE_CURSORS = "1";
    };

    pointerCursor = {
      enable = true;
      gtk.enable = true;
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

    foot = {
      enable = true;
      server.enable = true;
      settings = {
        main = {
          include = [
            "${pkgs.foot.themes}/share/foot/themes/starlight"
          ];
          dpi-aware = "yes";
          font = "${fonts.term.name}:weight=${fonts.term.weight}:size=${fonts.term.size}";
          line-height = 14;
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
        font = "${fonts.gui.name} ${fonts.gui.weight} ${fonts.gui.size}";
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
        font = "${fonts.gui.name} ${fonts.gui.weight} ${fonts.gui.size}";
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
        events = {
          "before-sleep" = "(display \"off\") ; lock";
          "after-resume" = "display \"on\"";
          "lock" = "(display \"off\");  lock";
          "unlock" = "display \"on\"";
        };
      };
  };

  xdg = {
    autostart.enable = true;
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

        sway = {
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
      "waybar".source = ./waybar;
      # "gtk-3.0/settings.ini".text = ''
      # [Settings]
      # gtk-font-name = "${fonts.gui.name} ${fonts.gui.weight} ${fonts.gui.size}";
      # gtk-theme-name = Adwaita
      # gtk-icon-theme-name = Adwaita
      # gtk-cursor-theme-name = Adwaita
      # gtk-cursor-theme-size = 48
      # gtk-xft-dpi = 196608  # 196608 = 2.0 * 96 * 1024
      # '';
      # "gtk-4.0/settings.ini".text = ''
      # [Settings]
      # gtk-font-name = "${fonts.gui.name} ${fonts.gui.weight} ${fonts.gui.size}";
      # gtk-cursor-theme-size = 48
      # '';
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
        "text/html" = "librewolf.desktop";
        "video/mp4" = "vlc.desktop";
        "x-scheme-handler/about" = "librewolf.desktop";
        "x-scheme-handler/http" = "librewolf.desktop";
        "x-scheme-handler/https" = "librewolf.desktop";
        "x-scheme-handler/tokodon" = "tokodon-handler.desktop";
        "x-scheme-handler/unknown" = "librewolf.desktop";
      };
    };
  };
}
