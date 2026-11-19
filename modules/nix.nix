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
      flake = "/etc/nixos";
      clean.enable = true;
      clean.extraArgs = "--keep-since 4w";
    };
  };

  nix = {
    settings = {
      download-buffer-size = 524288000;
      substituters = [ "https://slaxor.cachix.org" ];
      trusted-public-keys = [ "slaxor.cachix.org-1:XRZumwBtZlRCjWbGgAWM2BK8DSONEGe81u14gLRz9x4=" ];
    };
    # Not used. I use nh, which manages gc differently.
    # gc = {
    # automatic = true;
    # dates = "weekly";
    # options = "--delete-older-than 30d";
    # };
  };
}
