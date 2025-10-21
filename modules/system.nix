{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    neovim
    git
    wget
    curl
    htop
    nixfmt-rfc-style
  ];

  environment.systemPackages = [ pkgs.nixfmt-rfc-style ];
  formatter.x86_64-linux = pkgs.nixfmt-rfc-style
  services.openssh.enable = true;
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  system.stateVersion = "25.05";
}
