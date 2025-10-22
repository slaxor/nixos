{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    curl
    git
    htop
    neovim
    nixfmt-rfc-style
    wget
  ];

  environment.systemPackages = [ pkgs.nixfmt-rfc-style ];
  formatter.x86_64-linux = pkgs.nixfmt-rfc-style
  services.openssh.enable = true;
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  system.stateVersion = "25.05";
}
