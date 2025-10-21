{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vim git wget curl htop
  ];

  services.openssh.enable = true;
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "25.05";
}
