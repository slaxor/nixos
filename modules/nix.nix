{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    niv
  ];

  nix = {
    settings = {
      download-buffer-size = 524288000;
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
}
