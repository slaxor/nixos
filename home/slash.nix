{ config, pkgs, ... }:
{
  home.username = "slash";
  home.homeDirectory = "/home/slash";
  home.stateVersion = "25.05";

  programs.zsh.enable = true;
  programs.git = {
    enable = true;
    userName = "Sascha Teske";
    userEmail = "sascha.teske@microprojects.de";
  };

  home.packages = with pkgs; [
    alacritty
    avidemux
    discord
    ffmpeg_6-full
    foot
    gnupg
    go
    grim
    htop
    jq
    librewolf
    mako
    neovim
    tmux
    pkgs.kitty
    rustup
    slurp
    sway
    swaybg
    waybar
    wl-clipboard
    wlogout
    yazi
  ];

  
  xdg.configFile."sway/config".source = ./sway/config;
  xdg.configFile."sway/config.d".source = ./sway/config.d;
  # xdg.configFile."waybar/config.jsonc".source = ./sway/waybar/config.jsonc;
  # xdg.configFile."waybar/style.css".source = ./sway/waybar/style.css;
  # xdg.configFile."mako/config".source = ./sway/mako/config;

  # home.file."Pictures/background.jpg".source = ./sway/background.jpg;

  services.mako.enable = true;
  services.mako.package = pkgs.mako;
}

