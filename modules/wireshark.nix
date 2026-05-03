{ pkgs, ... }:
{
  programs.wireshark = {
    enable = true;
    # package = pkgs.unstable.wireshark; # full GUI, not wireshark-cli
  };
  # security.capabilities = {
  # "dumpcap" = true;
  # "wireshark" = [
  # "cap_net_raw"
  # "cap_net_admin"
  # ];
  # };

  # system.activationScripts.setDumpcapCapabilities = ''
  # setcap cap_net_raw,cap_net_admin=eip ${pkgs.unstable.wireshark}/bin/dumpcap
  # '';
  # users.groups.wireshark = { };
  users.users.slash = {
    extraGroups = [ "wireshark" ];
  };
  services.udev.extraRules = ''
    SUBSYSTEM=="usbmon", GROUP="wireshark", MODE="0640"
  '';
}
