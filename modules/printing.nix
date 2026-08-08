{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    brlaser
  ];

  # services.avahi = {
  # enable = true;
  # nssmdns4 = true; # Allows resolving .local addresses
  # openFirewall = true; # Opens the UDP port 5353 for discovery
  # };

  # networking.firewall.allowedTCPPorts = [ 9100 ];

  services.printing = {
    enable = true;
    drivers = [ pkgs.brlaser ];
    browsing = false;
    defaultShared = false;
  };

  hardware.printers = {
    ensurePrinters = [
      {
        name = "Brother_HL-5450DN";
        location = "Home";
        deviceUri = "socket://192.168.181.24:9100";
        model = "drv:///brlaser.drv/br5450d.ppd";
        ppdOptions = {
          PageSize = "A4";
        };
      }
    ];
    ensureDefaultPrinter = "Brother_HL-5450DN";
  };
}
