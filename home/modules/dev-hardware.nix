{ pkgs, ... }:
{
  home.packages = with pkgs; [
    (lib.lowPrio nrf-command-line-tools.override { segger-jlink = segger-jlink-headless; })
    nrfconnect
    nrfconnect-bluetooth-low-energy
    nrfutil
    pulseview
    sigrok-cli
    smuview
    tio
  ];

  xdg.configFile = {
    "tio/config".text = ''
      [default]
      baudrate = 115200
      databits = 8
      parity = none
      stopbits = 1
      color = 10

      [rpi3]
      device = /dev/serial/by-id/usb-FTDI_TTL232R-3V3_FTGQVXBL-if00-port0
      no-reconnect = true
      log = true
      log-file = rpi3.log
      line-pulse-duration = DTR=200,RTS=150
      color = 11

      [svf2]
      device = /dev/ttyUSB0
      baudrate = 9600
      script = tio.expect("login: "); tio.write("root\n"); tio.expect("Password: "); tio.write("root\n")
      color = 12

      [esp32]
      device = /dev/serial/by-id/usb-0403_6014-if00-port0
      script = tio.set{DTR=high,RTS=low}; tio.msleep(100); tio.set{DTR=low,RTS=high}; tio.msleep(100); tio.set{RTS=low}
      script-run = once
      color = 13

      [usb-devices]
      pattern = ^usb([0-9]*)
      baudrate = 115200
      device = /dev/ttyUSB%m1
      color = 10

      [bus-pirate4]
      pattern = ^bp4$
      baudrate = 115200
      device = /dev/serial/by-id/usb-Dangerous_Prototypes_Bus_Pirate_V4_00000001-if00
      color = 1

      [acm-devices]
      pattern = ^acm([0-9]*)
      baudrate = 115200
      device = /dev/ttyACM%m1
      color = 11

      [slow-usb-devices]
      pattern = ^susb([0-9]*)
      baudrate = 9600
      device = /dev/ttyUSB%m1
      color = 12

      [slow-acm-devices]
      pattern = ^sacm([0-9]*)
        baudrate = 9600
      device = /dev/ttyACM%m1
      color = 13
    '';
  };
}
