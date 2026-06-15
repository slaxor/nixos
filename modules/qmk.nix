{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vial
    keymapviz
    qmk-udev-rules
    qmk_hid
    qmk
  ];
}
