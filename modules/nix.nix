{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    niv
  ];

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 14d --keep 8";
    flake = "/home/slash/git/codeberg.org/slaxor/nixos"; # sets NH_OS_FLAKE variable for you
  };

  nix = {
    settings = {
      download-buffer-size = 524288000;
    };

    # gc = {
    # automatic = true;
    # dates = "weekly";
    # options = "--delete-older-than 30d";
    # };
  };
}
