{ pkgs, ... }:
let
  thonny = pkgs.thonny.overrideAttrs {
    postPatch = ''
      sed -i 's/uv_build>=\([0-9.]*\),<[0-9.]*/uv_build>=\1/' pyproject.toml
    '';
  };
in
{
  home.packages =
    with pkgs;
    [
      pgcli
      python313
      thonny
    ]
    ++ (with python313Packages; [
      mkdocs-macros
      mkdocs-material
      mkdocs-material-extensions
      mkdocs-mermaid2-plugin
      mkdocs
      uv
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
