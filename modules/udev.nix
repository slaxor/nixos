{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    apio-udev-rules
    biosdevname
    finalmouse-udev-rules
    game-devices-udev-rules
    keychron-udev-rules
    ledger-udev-rules
    meletrix-udev-rules
    nitrokey-udev-rules
    nrf-udev
    numworks-udev-rules
    picoprobe-udev-rules
    qmk-udev-rules
    rfkill_udev
    steam-devices-udev-rules
    # teensy-udev-rules
    trezor-udev-rules
    udev-block-notify
    usb-blaster-udev-rules
    wooting-udev-rules
    zsa-udev-rules
  ];

  users.groups.plugdev = {
    gid = 713;
  };

  services.udev = {
    packages = [
      pkgs.libsigrok
      pkgs.probe-rs-tools
    ];
    extraRules = ''
      KERNEL=="uinput", MODE="0660", GROUP="input"

      # all USB devices belong to plugdev and are group writable
      SUBSYSTEM=="usb", MODE="0660", GROUP="plugdev"

      # oscilloscope via usb
      SUBSYSTEM=="usbmisc", KERNEL=="usbtmc*", MODE="0660", GROUP="plugdev"

      # Match Logitech Unifying Receiver (Solaar)
      SUBSYSTEM=="usb", ATTR{idVendor}=="046d", ATTR{idProduct}=="c548", MODE="0660", GROUP="plugdev"
    '';
  };
}
