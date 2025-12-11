{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    unstable.wireshark
  ];

  # security.capabilities = {
  # "dumpcap" = true;
  # "wireshark" = [
  # "cap_net_raw"
  # "cap_net_admin"
  # ];
  # };
  users.groups.wireshark = { };
  users.users.slash = {
    extraGroups = [ "wireshark" ];
  };

  # system.activationScripts.setDumpcapCapabilities = ''
  # setcap cap_net_raw,cap_net_admin=eip ${pkgs.unstable.wireshark}/bin/dumpcap
  # '';

}
