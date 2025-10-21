{ pkgs, ... }:
{
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = false;
  services.resolved.enable = true;

  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [
    vim git wget curl htop
  ];

  programs.zsh.enable = true;
}
