{ pkgs, ... }:
let
  signal = 8;
  charge-limit-status = pkgs.writeShellApplication {
    name = "charge-limit-status";
    text = ''
      max=$(charge-limit get) || max=""
      case "$max" in
        100) alt=full ;;
        "") alt=unknown ;;
        *) alt=limited ;;
      esac
      printf '{"alt":"%s","class":"%s","tooltip":"charge limit: %s%%"}\n' "$alt" "$alt" "$max"
    '';
  };
in
{
  programs.waybar.settings.mainBar."custom/charge-limit" = {
    exec = "${charge-limit-status}/bin/charge-limit-status";
    on-click = "charge-limit toggle && pkill -RTMIN+${toString signal} waybar";
    return-type = "json";
    interval = 300;
    inherit signal;
    format = "{icon}";
    format-icons = {
      limited = "󰂁";
      full = "󰁹";
      unknown = "󰂑";
    };
  };
}
