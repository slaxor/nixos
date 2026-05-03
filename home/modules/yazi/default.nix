{ pkgs-unstable, ... }:
{
  home.packages = with pkgs-unstable; [
    yazi
  ];

  home.shellAliases = {
    y = "${pkgs-unstable.yazi}/bin/yazi";
  };

  programs.yazi = {
    enable = true;
    package = pkgs-unstable.yazi;
    plugins = with pkgs-unstable.yaziPlugins; {
      inherit
        bypass
        chmod
        mediainfo
        miller
        ouch
        rich-preview
        smart-enter
        toggle-pane
        ;
    };
    settings = {
      mgr = {
        ratio = [
          1
          3
          4
        ];
        sort_by = "natural";
        sort_sensitive = true;
        sort_reverse = false;
        sort_dir_first = true;
        linemode = "none";
        show_hidden = true;
        show_symlink = true;
      };

      preview = {
        image_filter = "lanczos3";
        image_quality = 90;
        tab_size = 1;
        max_width = 600;
        max_height = 900;
        cache_dir = "";
        ueberzug_scale = 1;
        ueberzug_offset = [
          0
          0
          0
          0
        ];
      };

      tasks = {
        micro_workers = 5;
        macro_workers = 10;
        bizarre_retry = 5;
      };
    };

    # flavors = { inherit (pkgs.yaziPlugins) nord; };
    # theme.flavor = {
    # light = "nord";
    # dark = "nord";
    # };

    # initLua = /* lua */ ''
    # '';

  };

  # xdg.configFile = {
  # "yazi/init.lua".text = ''
  # require("smart-enter"):setup {
  # open_multi = true,
  # }
  # require("githead"):setup({
  # theme = your_theme,
  # });
  # '';
  # };
}

# plugins = with pkgs-unstable.yaziPlugins; {
# rich-preview = rich-preview;
# wl-clipboard = wl-clipboard;
# bypass = bypass
# chmod = chmod
# diff = diff
# duckdb = duckdb
# dupes = dupes
# "full-border" = "full-border"
# git = git
# gitui = gitui
# glow = glow
# "jump-to-char" = "jump-to-char"
# lazygit = lazygit
# lsar = lsar
# mediainfo = mediainfo
# miller = miller
# "mime-ext" = "mime-ext"
# mount = mount
# "no-status" = "no-status"
# nord = nord
# ouch = ouch
# piper = piper
# projects = projects
# "recycle-bin" = "recycle-bin"
# "relative-motions" = "relative-motions"
# restore = restore
# rsync = rsync
# "smart-enter" = "smart-enter"
# "smart-filter" = "smart-filter"
# "smart-paste" = "smart-paste"
# starship = starship
# sudo = sudo
# "time-travel" = "time-travel"
# "toggle-pane" = "toggle-pane"
# "vcs-files" = "vcs-files"
# yatline = yatline
# "yatline-catppuccin" = "yatline-catppuccin"
# "yatline-githead" = "yatline-githead"
# };
