{ pkgs, ... }:
{
  home.packages =
    with pkgs;
    [
      pgcli
      python313
    ]
    ++ (with python313Packages; [
      mkdocs-macros
      mkdocs-material
      mkdocs-material-extensions
      mkdocs-mermaid2-plugin
      mkdocs
      uv
      thonny
      mpremote
    ]);

  # home = {
  # sessionVariables = {
  # NIXOS_OZONE_WL = "1";
  # };

  # programs = {
  # };

  # services = {
  # };

  # xdg.configFile = {
  # "gtk-4.0/settings.ini".text = ''
  # [Settings]
  # gtk-font-name = Noto Sans 12
  # gtk-cursor-theme-size = 48
  # '';
  # };

  # mimeApps = {
  # defaultApplications = {
  # "inode/directory" = "thunar.desktop";
  # };
  # };
  # };
  # home.file.".xkb".source = ./.xkb;
}
