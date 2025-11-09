{ ... }:
{
  networking = {
    networkmanager.enable = true;
    firewall = {
      allowedTCPPorts = [ 22 ];
      # allowedUDPPorts = [ ... ];
      # enable = false;
    };
  };

  programs = {
    ssh = {
      startAgent = true;
      enableAskPassword = true;
    };
  };

  services = {
    resolved.enable = true;
    openssh = {
      enable = true;
      settings.KbdInteractiveAuthentication = false;
    };
  };
}
