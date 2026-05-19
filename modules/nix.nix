{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    niv
    nixd
    nix-diff
    nixdoc
    nixfmt-rfc-style
  ];

  programs = {
    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 14d --keep 8";
    };
  };

  nix = {
    settings = {
      download-buffer-size = 524288000;
    };
  };
}
