{ fonts }:
{ ... }:
{
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = [
      {
        height = 35;
        spacing = 4;
        "modules-left" = [
          "sway/workspaces"
          "sway/mode"
          "sway/scratchpad"
          "custom/media"
        ];
        "modules-center" = [ ];
        "modules-right" = [
          "disk"
          "cpu"
          "memory"
          "temperature#thinkpad"
          "network"
          "backlight"
          "idle_inhibitor"
          "custom/pipewire"
          "custom/weather"
          "clock"
          "battery"
          "custom/session"
          "tray"
        ];

        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "";
            deactivated = "";
          };
        };

        tray = {
          show-passive-items = true;
          icon-size = 18;
          spacing = 5;
        };

        clock = {
          timezone = "Europe/Berlin";
          tooltip-format = "<big>{:%B %Y}</big>\n<tt><small>{calendar}</small></tt>";
          format = "<big>{:%a %d.%m.%y %H:%M}</big>";
        };

        "custom/weather" = {
          format = "{} °";
          tooltip = true;
          interval = 3600;
          exec = "wttrbar --date-format '%d.%m.%y' --nerd --lang de --observation-time --location Hamburg";
          return-type = "json";
        };

        cpu = {
          format = " {icon}";
          format-alt = "{icon0} {icon1} {icon2} {icon3} {icon4} {icon5} {icon6} {icon7} {icon8} {icon9} {icon10} {icon11}";
          format-icons = [
            "▁"
            "▂"
            "▃"
            "▄"
            "▅"
            "▆"
            "▇"
            "█"
          ];
        };

        memory = {
          format = "𝄜 {icon}";
          format-alt = " {}%";
          format-icons = [
            "▏"
            "▎"
            "▍"
            "▌"
            "▋"
            "▊"
            "▉"
          ];
        };

        "temperature#zone0" = {
          format = "{icon}";
          format-alt = "zone0 {temperatureC}°C";
          format-critical = ''<span background="red">zone0 {temperatureC}°C</span>'';
          hwmon-path = "/sys/devices/virtual/thermal/thermal_zone0/hwmon1/temp1_input";
          critical-threshold = 80;
          format-icons = [
            "⛄"
            ""
            "☕"
          ];
        };

        "temperature#zone2" = {
          format = "{icon}";
          format-alt = "zone2 {temperatureC}°C";
          format-critical = ''<span background="red">zone2 {temperatureC}°C</span>'';
          hwmon-path = "/sys/devices/virtual/thermal/thermal_zone2/hwmon8/temp1_input";
          critical-threshold = 80;
          format-icons = [
            "⛄"
            ""
            "☕"
          ];
        };

        "temperature#zone9" = {
          format = "{icon}";
          format-alt = "zone9 {temperatureC}°C";
          format-critical = ''<span background="red">zone9 {temperatureC}°C</span>'';
          hwmon-path = "/sys/devices/virtual/thermal/thermal_zone9/hwmon11/temp1_input";
          critical-threshold = 80;
          format-icons = [
            "⛄"
            ""
            "☕"
          ];
        };

        "temperature#nvme0" = {
          format = "{icon}";
          format-alt = "nvme0 {temperatureC}°C";
          format-critical = ''<span background="red">nvme0 {temperatureC}°C</span>'';
          hwmon-path = "/sys/devices/pci0000:00/0000:00:1b.0/0000:02:00.0/nvme/nvme0/hwmon4/temp1_input";
          critical-threshold = 80;
          format-icons = [
            "⛄"
            ""
            "☕"
          ];
        };

        "temperature#nvme1" = {
          format = "{icon}";
          format-alt = "nvme1 {temperatureC}°C";
          format-critical = ''<span background="red">nvme1 {temperatureC}°C</span>'';
          hwmon-path = "/sys/devices/pci0000:00/0000:00:1d.0/0000:55:00.0/nvme/nvme1/hwmon3/temp1_input";
          critical-threshold = 80;
          format-icons = [
            "⛄"
            ""
            "☕"
          ];
        };

        "temperature#core0" = {
          format = "{icon}";
          format-alt = "core {temperatureC}°C";
          format-critical = ''<span background="red">core {temperatureC}°C</span>'';
          hwmon-path = "/sys/devices/platform/coretemp.0/hwmon/hwmon9/temp1_input";
          critical-threshold = 80;
          format-icons = [
            "⛄"
            ""
            "☕"
          ];
        };

        "temperature#thinkpad" = {
          format = "{icon}";
          format-alt = "thinkpad {temperatureC}°C";
          format-critical = ''<span background="red">thinkpad {temperatureC}°C</span>'';
          hwmon-path = "/sys/devices/platform/thinkpad_hwmon/hwmon/hwmon5/temp1_input";
          critical-threshold = 80;
          format-icons = [
            "⛄"
            ""
            "☕"
          ];
        };

        backlight = {
          device = "acpi_video1";
          tooltip-format = "Screen brightness is at {percent}%";
          format = "{icon}";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
          ];
          on-scroll-up = "ydotool key --key-delay 0 225:1 225:0";
          on-scroll-down = "ydotool key --key-delay 0 224:1 224:0";
        };

        battery = {
          states = {
            good = 95;
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          format-charging = "{capacity}% ";
          format-plugged = "{capacity}% ";
          format-alt = "{time} {icon}";
          format-good = ":)";
          format-full = "";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
          ];
        };

        disk = {
          interval = 300;
          format = "⛃ {percentage_used}%";
          path = "/";
        };

        network = {
          format-wifi = "{essid} ({signalStrength}%) ";
          format-ethernet = "{ipaddr}/{cidr} ";
          tooltip-format = "{ifname} via {gwaddr} ";
          format-linked = "{ifname} (No IP) ";
          format-disconnected = "Disconnected ⚠";
          format-alt = "{ifname}: {ipaddr}/{cidr}";
        };

        "custom/pipewire" = {
          format = "{}";
          tooltip = false;
          exec = "$HOME/.config/waybar/scripts/pipewire.sh";
          on-click = "pwvucontrol";
          on-click-middle = "qpwgraph";
          on-click-right = "carla";
          on-scroll-up = "ydotool key 115:1 115:0";
          on-scroll-down = "ydotool key 114:1 114:0";
        };

        "custom/wl-gammarelay-temperature" = {
          format = "{} ";
          exec = "wl-gammarelay-rs watch {t}";
          on-scroll-up = "busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateTemperature n +100";
          on-scroll-down = "busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateTemperature n -100";
        };

        "custom/wl-gammarelay-brightness" = {
          format = "{}% ";
          exec = "wl-gammarelay-rs watch {bp}";
          on-scroll-up = "busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateBrightness d +0.02";
          on-scroll-down = "busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateBrightness d -0.02";
        };

        "custom/wl-gammarelay-gamma" = {
          format = "{}% γ";
          exec = "wl-gammarelay-rs watch {g}";
          on-scroll-up = "busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateGamma d +0.02";
          on-scroll-down = "busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateGamma d -0.02";
        };

        pulseaudio = {
          scroll-step = 1;
          format = "{volume}% {icon} {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = " {icon} {format_source}";
          format-muted = " {format_source}";
          format-source = "{volume}% ";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [
              ""
              ""
              ""
            ];
          };
          on-click = "pavucontrol";
        };

        "custom/media" = {
          format = "{icon} {}";
          return-type = "json";
          max-length = 40;
          format-icons = {
            spotify = "";
            default = "🎜";
          };
          escape = true;
          exec = "$HOME/.config/waybar/mediaplayer.py";
        };

        user = {
          format = "{user} (up {work_d} days ↑)";
          interval = 60;
          height = 30;
          width = 90;
          icon = true;
          on-click = "pavucontrol";
        };

        "custom/session" = {
          format = "{}";
          exec = "echo -n $(whoami)";
          return-type = "string";
          interval = "once";
          on-click = "$HOME/.config/waybar/scripts/session_switcher.sh";
        };
      }
    ];

    style = ''
      * {
        font-family: "${fonts.gui.name}";
        font-weight: 500;
        font-size: ${fonts.gui.size}px;
      }

      tooltip {
        background-color: rgba(0xad, 0xbc, 0xbc, 0.9);
        border-bottom: 3px solid rgba(0xb4, 0xc4, 0xc4, 0.9);
        transition-property: background-color;
        transition-duration: 0.5s;
      }

      tooltip label {
        font-size: 10pt;
        color: rgba(0x10, 0x3c, 0x48, 0.9);
      }

      window#waybar {
        background-color: rgba(43, 48, 59, 0.5);
        border-bottom: 3px solid rgba(100, 114, 125, 0.5);
        color: #F0932B;
      }

      button {
        box-shadow: inset 0 -3px transparent;
        border: none;
        border-radius: 0;
      }

      button:hover {
        background: inherit;
        box-shadow: inset 0 -3px #ffffff;
      }

      @keyframes blink {
        to {
          background-color: #ffffff;
          color: #000000;
        }
      }

      window#waybar.hidden { opacity: 0.2; }
      window#waybar.termite { background-color: #3f3f3f; }
      window#waybar.chromium { background-color: #000000; border: none; }

      #workspaces button {
        padding: 0 5px;
        background-color: transparent;
        color: #ffffff;
      }

      #workspaces button:hover { background: rgba(0, 0, 0, 0.2); }

      #workspaces button.focused {
        background-color: #64727d;
        box-shadow: inset 0 -3px #ffffff;
      }

      #workspaces button.urgent { background-color: #eb4d4b; }

      #mode {
        background-color: #64727d;
        border-bottom: 3px solid #ffffff;
      }

      #backlight, #battery, #clock, #cpu, #custom-media, #custom-pipewire,
      #custom-session, #custom-weather, #disk, #idle_inhibitor, #memory,
      #mode, #mpd, #network, #pulseaudio, #scratchpad, #temperature,
      #tray, #wireplumber {
        border-radius: 2px;
        padding: 0 10px;
        color: #ffffff;
      }

      #clock {
        font-size: 55%;
        margin: 0;
        padding: 0;
        background-color: #64727d;
      }

      #window, #workspaces { margin: 0 4px; }

      .modules-left > widget:first-child > #workspaces { margin-left: 0; }
      .modules-right > widget:last-child > #workspaces { margin-right: 0; }

      #battery { background-color: #ffffff; color: #000000; }
      #battery.charging, #battery.plugged { color: #ffffff; background-color: #26a65b; }

      #battery.critical:not(.charging) {
        background-color: #f53c3c;
        color: #ffffff;
        animation-name: blink;
        animation-duration: 0.5s;
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
      }

      label:focus { background-color: #000000; }

      #cpu { background-color: #296919; }
      .load { font-size: 25%; color: #000000; }
      #memory { background-color: #9b59b6; }
      #custom-session { background-color: #186357; }
      #disk { background-color: #964b00; }
      #backlight { background-color: #446161; }
      #network { background-color: #2980b9; }
      #network.disconnected { background-color: #f53c3c; }
      #pulseaudio { background-color: #f1c40f; color: #000000; }
      #pulseaudio.muted { background-color: #90b1b1; color: #2a5c45; }
      #wireplumber { background-color: #fff0f5; color: #000000; }
      #wireplumber.muted { background-color: #f53c3c; }

      #custom-media {
        background-color: #66cc99;
        color: #2a5c45;
        min-width: 100px;
      }

      #custom-media.custom-spotify { background-color: #66cc99; }
      #custom-media.custom-vlc { background-color: #ffa000; }
      #temperature { background-color: #f0932b; }
      #temperature.critical { background-color: #eb4d4b; }
      #tray { background-color: #2980b9; }
      #tray > .passive { -gtk-icon-effect: dim; }
      #tray > .needs-attention { -gtk-icon-effect: highlight; background-color: #eb4d4b; }
      #idle_inhibitor { background-color: #2d3436; }
      #idle_inhibitor.activated { background-color: #ecf0f1; color: #2d3436; }

      #mpd { background-color: #66cc99; color: #2a5c45; }
      #mpd.disconnected { background-color: #f53c3c; }
      #mpd.stopped { background-color: #90b1b1; }
      #mpd.paused { background-color: #51a37a; }

      #language {
        background: #00b093;
        color: #740864;
        padding: 0 5px;
        margin: 0 5px;
        min-width: 16px;
      }

      #keyboard-state {
        background: #97e1ad;
        color: #000000;
        padding: 0;
        margin: 0 5px;
        min-width: 16px;
      }

      #keyboard-state > label { padding: 0 5px; }
      #keyboard-state > label.locked { background: rgba(0, 0, 0, 0.2); }
      #scratchpad { background: rgba(0, 0, 0, 0.2); }
      #scratchpad.empty { background-color: transparent; }
    '';
  };
}
