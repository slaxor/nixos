{ pkgs-unstable, ... }:
{
  home.packages = with pkgs-unstable; [
    # spicedb
    spicedb-zed
  ];

}
