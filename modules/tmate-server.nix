{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    tmate-ssh-server
  ];

  services.tmate-ssh-server = {
     enable = true ;
     advertisedPort = 2222;  # External port advertised to clients
     # keysDir = ""; # Directory containing ssh keys, defaulting to auto-generation
     openFirewall = true; # Whether to automatically open the specified ports in the firewall
     # package = ""; # The tmate-ssh-server package to use
     port = 2222; # Listen port for the ssh server
   };
 }

