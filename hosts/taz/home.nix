{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    algia
    vivid
    swappy
    satty
    tray-tui
    ghostty
    cavalier
    podman
    podman-tui
    podman-bootc
    podman-compose
    podman-desktop
  ];

  services = {
    wluma = {
      enable = true;
      settings = {
        als = {
          # iio = {
          # path = "/sys/bus/iio/devices";
          # thresholds = {
          # "0" = "night";
          # "20" = "dark";
          # "250" = "normal";
          # "500" = "bright";
          # "80" = "dim";
          # "800" = "outdoors";
          # };
          # };
          # webcam = {
          # video = 2;
          # thresholds = {
          # "0" = "night";
          # "15" = "dark";
          # "30" = "dim";
          # "45" = "normal";
          # "60" = "bright";
          # "75" = "outdoors";
          # };
          # };

          time = {
            thresholds = {
              "0" = "night";
              "7" = "dark";
              "9" = "dim";
              "11" = "normal";
              "13" = "bright";
              "16" = "normal";
              "18" = "dark";
              "20" = "night";
            };
          };

          # none = { };
        };
        output = {
          backlight = [
            {
              name = "eDP-1";
              path = "/sys/class/backlight/intel_backlight";
              capturer = "wayland";
            }

            # ddcutil = {
            # name = "Dell Inc. DELL P2415Q";
            # capturer = "none";
            # };
          ];
        };
        keyboard = [
          # {
          # name = "keyboard-dell";
          # path = "/sys/bus/platform/devices/dell-laptop/leds/dell::kbd_backlight";
          # }
          {
            name = "keyboard-thinkpad";
            path = "/sys/bus/platform/devices/thinkpad_acpi/leds/tpacpi::kbd_backlight";
          }
        ];
      };
    };
  };
  home.stateVersion = "25.11";
}
