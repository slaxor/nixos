{ pkgs, ... }:
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
          iio = {
            path = "/sys/bus/iio/devices";
            thresholds = {
              "0" = "night";
              "20" = "dark";
              "250" = "normal";
              "500" = "bright";
              "80" = "dim";
              "800" = "outdoors";
            };
          };
        };
        output = {
          backlight = [
            {
              name = "eDP-2";
              path = "/sys/class/backlight/amdgpu_bl0/brightness";
              capturer = "wayland";
            }
          ];
        };
        keyboard = [
          {
            name = "qmk-ansi";
            path = "/sys/bus/platform/devices/thinkpad_acpi/leds/tpacpi::kbd_backlight";
          }
          {
            name = "qmk-macro";
            path = "/sys/bus/platform/devices/thinkpad_acpi/leds/tpacpi::kbd_backlight";
          }
        ];
      };
    };
  };
  home.stateVersion = "25.11";
}
