{ ... }:

{
  wayland.windowManager.sway.config = {
    input = {
      "type:keyboard" = {
        xkb_layout = "us-german-umlaut";
      };
    };
    focus = {
      followMouse = false;
      mouseWarping = "none";
    };
  };
}
