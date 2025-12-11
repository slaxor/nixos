{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    cups
    brlaser
  ];

  services = {

    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = false;
      publish = {
        enable = false;
        userServices = false;
      };
    };
    printing = {
      listenAddresses = [ "127.0.0.1:631" ];
      allowFrom = [ "none" ];
      browsing = true;
      defaultShared = false;
      openFirewall = false;
    };

    hardware.printers = {
      ensurePrinters = [
        {
          name = "Brother_HL-5450";
          location = "Home";
          deviceUri = "http://192.168.178.49:631/printers/Brother_HL-5450";
          model = "drv:///sample.drv/generic.ppd";
          ppdOptions = {
            PageSize = "A4";
          };
        }
      ];
      ensureDefaultPrinter = "Brother_HL-5450";
    };
  };
}
