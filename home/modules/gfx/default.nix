{ pkgs, ... }:
{
  home.packages = with pkgs; [
    gimp
    sane-airscan
    xsane
    simple-scan
    sane-backends
    # sane-drivers
    sane-frontends
  ];
}
