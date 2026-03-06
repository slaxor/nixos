{ config, pkgs, ... }:
{
  users.groups.plugdev = {
    gid = 713;
  };

  services.udev.extraRules = ''
    # all USB devices belong to plugdev
    SUBSYSTEM=="usb", MODE="0660", GROUP="plugdev"

    KERNEL=="uinput", MODE="0660", GROUP="input"
  '';
  # services.udev.extraRules = ''
  # Match Logitech Unifying Receiver (Solaar)
  # SUBSYSTEM=="usb", ATTR{idVendor}=="046d", ATTR{idProduct}=="c548", MODE="0660", GROUP="plugdev"
  # '';
  services.udev.packages = [
    pkgs.probe-rs-tools
  ];
  # users.users.slash.extraGroups = [ "dialout" ];
}
