{ pkgs, lib, ... }:

let
  mod = "Mod4"; # $cmd
  alt = "Mod1"; # $alt
  # term = "foot";
  term = "${(lib.getExe pkgs.kitty)}";
  launcher = "${(lib.getExe pkgs.fuzzel)}";
in

{
  wayland.windowManager.sway.config = {
    modifier = mod;
    terminal = term;
    menu = launcher;

    # lib.mkOptionDefault preserves home-manager's default bindings and adds these on top.
    # Remove it and use a plain attrset if you want full control over all keybindings.
    keybindings = lib.mkOptionDefault {
      "${mod}+space" = "exec ${launcher}";
      "${mod}+0" = "workspace number 10";
      "${mod}+1" = "workspace number 1";
      "${mod}+2" = "workspace number 2";
      "${mod}+3" = "workspace number 3";
      "${mod}+4" = "workspace number 4";
      "${mod}+5" = "workspace number 5";
      "${mod}+6" = "workspace number 6";
      "${mod}+7" = "workspace number 7";
      "${mod}+8" = "workspace number 8";
      "${mod}+9" = "workspace number 9";
      "${mod}+d" = "workspace \"\"";

      "${mod}+Shift+0" = "move container to workspace number 10";
      "${mod}+Shift+1" = "move container to workspace number 1";
      "${mod}+Shift+2" = "move container to workspace number 2";
      "${mod}+Shift+3" = "move container to workspace number 3";
      "${mod}+Shift+4" = "move container to workspace number 4";
      "${mod}+Shift+5" = "move container to workspace number 5";
      "${mod}+Shift+6" = "move container to workspace number 6";
      "${mod}+Shift+7" = "move container to workspace number 7";
      "${mod}+Shift+8" = "move container to workspace number 8";
      "${mod}+Shift+9" = "move container to workspace number 9";

      # Focus
      "${mod}+Left" = "focus left";
      "${mod}+Right" = "focus right";
      "${mod}+Up" = "focus up";
      "${mod}+Down" = "focus down";

      # Move
      "${mod}+Shift+Left" = "move left";
      "${mod}+Shift+Right" = "move right";
      "${mod}+Shift+Up" = "move up";
      "${mod}+Shift+Down" = "move down";

      # Move workspace to output
      "${mod}+Control+Left" = "move workspace to output left";
      "${mod}+Control+Right" = "move workspace to output right";
      "${mod}+Control+Up" = "move workspace to output up";
      "${mod}+Control+Down" = "move workspace to output down";

      # Layout
      "${mod}+e" = "layout toggle split";
      "${mod}+f" = "fullscreen";
      "${mod}+Shift+f" = "floating toggle";
      "${mod}+Shift+space" = "floating toggle";
      "${mod}+Shift+b" = "focus parent";
      "${mod}+r" = "mode resize";

      # Terminals
      "${mod}+Return" = "exec ${term} -e tmux";
      "${mod}+Ctrl+Return" = "exec ${term}";
      "${mod}+Shift+Return" = "exec ${term} --title='foot (root)' -e sudo -i tmux";

      # Apps
      "${mod}+a" = "exec pwvucontrol";
      "${mod}+l" = "exec dm-tool lock";
      "${mod}+n" = "exec foot -a yazi -T yazi -e yazi";
      "${mod}+p" =
        "exec gopass ls --flat | dmenu | xargs --no-run-if-empty gopass show -f | head -n 1 | xdotool type --clearmodifiers --file -";
      "${mod}+v" = "exec clipcat-menu";
      "${mod}+Shift+a" = "exec ~/.config/sway/swaysnipper.sh";
      "${mod}+Shift+c" = "exec i3change_context.sh _";
      "${mod}+Shift+s" = "exec ~/.config/sway/scripts/toggle-scratchpad.sh";
      "${mod}+s" = "scratchpad show";
      "${mod}+Shift+Tab" = "move workspace back_and_forth";
      "${mod}+Tab" = "workspace back_and_forth";

      # Kill / reload / exit
      "${mod}+Shift+q" = "kill";
      "${mod}+ctrl+q" =
        "exec kill -9 ''$(swaymsg -t get_tree | jq '.. | select(.focused? == true) | .pid')";
      "${mod}+Shift+r" = "reload";
      "${mod}+Shift+e" =
        "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -B 'Yes, exit sway' 'swaymsg exit'";
      "${mod}+Control+Shift+q" = "exec --no-startup-id xkill";

      # Screenshot
      "Print" = "exec grim -g \"$(slurp -d)\" - | wl-copy";
      "Shift+Print" =
        "exec grim -g \"$(slurp)\" \"$\{HOME}/tmp/screenshot_$(date +%Y-%m-%d_%H%M%e).png\"";
      "${mod}+b" = "exec grim -g \"$(slurp -d)\" - | zbarimg --quiet - | wl-copy -pn";

      # Brightness
      "XF86MonBrightnessUp" =
        "exec notify-send -t 1000 -a 'brightness' \"$(brightnessctl -m set 20%+|awk -F, '{printf \"Bildschirmhelligeit ist jetzt %s\", $4}')\"";
      "XF86MonBrightnessDown" =
        "exec notify-send -t 1000 -a 'brightness' \"$(brightnessctl -m set 20%-|awk -F, '{printf \"Bildschirmhelligeit ist jetzt %s\", $4}')\"";

      # Audio
      "XF86AudioRaiseVolume" = "exec wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+ && wpvol";
      "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && wpvol";
      "XF86AudioMute" =
        "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && notify-send -t 1000 -a 'wp-vol' 'Stumm' || notify-send -t 1000 -a 'wp-vol' 'Eingeschaltet'";
    };

    floating.modifier = mod;

    modes.resize = {
      Left = "resize shrink width 10px";
      Right = "resize grow width 10px";
      Up = "resize shrink height 10px";
      Down = "resize grow height 10px";
      Return = "mode default";
      Escape = "mode default";
    };
  };

  # --no-repeat is not supported in home-manager keybindings attrset
  wayland.windowManager.sway.extraConfig = ''
    bindsym --no-repeat XF86Display exec wlay
    bindsym --no-repeat XF86Keyboard exec wvkbd-mobintl
    bindsym ${alt}+s exec alacritty --class 'snipkey' --command bash -c 'fzsnip | xargs -r swaymsg -t command exec'
  '';
}
