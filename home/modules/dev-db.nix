{
  pkgs-unstable,
  ...
}:
{
  home.packages = with pkgs-unstable; [
    dbeaver-bin
    dbtpl
    sqlitebrowser
  ];
}
