{ config, pkgs, ... }:
{
  # environment.systemPackages = with pkgs; [
  # ];
  nix = {
    settings = {
      # json-log-path = "/tmp/nixbtm.sock";
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
}
