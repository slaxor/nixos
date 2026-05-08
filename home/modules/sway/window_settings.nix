{ ... }:

{
  wayland.windowManager.sway.config = {
    assigns = {
      "1" = [
        { class = "(?i)firefox"; }
        { class = "(?i)chromium"; }
      ];
      "4" = [
        { title = "(?i)Xephyr"; }
      ];
      "6" = [
        { title = "(?i)Quick(LOAD|TARGET)"; }
      ];
    };

    floating.criteria = [
      { class = "(?i)scrcpy"; }
      { title = "Screen Layout Editor"; }
      { title = "(?i)wlay"; }
      { title = "(?i)yad"; }
      { title = "(?i)Event Tester"; }
      { title = "(?i)Switch session"; }
      { title = "File Operation Progress"; }
    ];

    window.commands = [
      # Kill blueman "connected" popups
      {
        criteria = {
          app_id = "blueman-applet";
          title = "Connected";
        };
        command = "kill";
      }
      {
        criteria = {
          app_id = "blueman-applet";
          title = "Verbunden";
        };
        command = "kill";
      }

      # devdocs on its own workspace, fullscreened
      {
        criteria = {
          app_id = "devdocs-desktop";
        };
        command = "move container to workspace \"\"; fullscreen enable";
      }

      # Inhibit idle when any app is fullscreen
      {
        criteria = {
          app_id = "^.*";
        };
        command = "inhibit_idle fullscreen";
      }

      # snipkey: floating, borderless, large centered popup
      {
        criteria = {
          app_id = "^snipkey$";
        };
        command = "floating enable, border none, resize set width 80 ppt height 60 ppt, move position 0 px 0 px";
      }

      # Red title bar for root terminals — pango markup requires extraConfig, see below
    ];
  };

  # title_format with pango markup has no structured home-manager equivalent
  wayland.windowManager.sway.extraConfig = ''
    for_window [title="(?i)root"] title_format <span foreground="#ff0000">%title</span>
  '';
}
