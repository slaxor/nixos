{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    niv
    nixd
    nix-diff
    nixdoc
    nixfmt
  ];

  programs = {
    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4w";
    };
  };

  nix = {
    settings = {
      download-buffer-size = 524288000;
    };
    # Not used. I use nh, which manages gc differently.
    # gc = {
    # automatic = true;
    # dates = "weekly";
    # options = "--delete-older-than 30d";
    # };
  };
}
