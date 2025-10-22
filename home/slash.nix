{ config, pkgs, ... }:
let
  secrets = config.sops.secrets;
  token = builtins.readFile secrets.github_token.path;
  imports = [ inputs.sops-nix.homeManagerModules.sops ];
  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    secrets.github_token.path = "${config.xdg.configHome}/github_token";
  };
in {
  home.username = "slash";
  home.homeDirectory = "/home/slash";
  home.stateVersion = "25.05";

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
  # sops.age.keyFile = "/home/slash/.config/sops/age/keys.txt";
  # sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  sops.defaultSopsFile = ./secrets.yml;
  sops.defaultSopsFormat = "yaml";


  # öffentlicher Teil der Git-Config
  xdg.configFile."git/config".source = ./git/config;

  # privater Teil (Token)
  programs.git = {
    enable = true;
    userName = "Sascha Teske";
    userEmail = "sascha.teske@microprojects.de";
    extraConfig = {
      "credential \"https://github.com\"" = {
        # helper = "!f() { echo username=slash; echo password=$(cat ${secrets.github_token.path}); }; f";
	helper = "!f() { echo username=slash; echo password=${token}; }; f";
      };
    };
  };

  sops.secrets.github_token = {
    sopsFile = ./secrets.yml;
    key = "github_token";
  };

  # sops.secrets.gitconfig = {
  #   format = "binary"; # .gitconfig is not a YAML
  #   sopsFile = ./.gitconfig.age;
  #   path = "${config.home.homeDirectory}/.gitconfig";
  # };
  sops.secrets.id_ed25519 = {
    format = "binary";
    sopsFile = ./.ssh/slash_kea/id_ed25519.age;
    path = "${config.home.homeDirectory}/.ssh/id_ed25519";
    mode = "0600";
  };
  home.file.".ssh/id_ed25519.pub".source = ./.ssh/slash_kea/id_ed25519.pub;
 
  home.file.".bashrc".source = ./.bashrc;
  home.file.".bashrc.d".source = ./.bashrc.d;
  home.file.".xkb".source = ./.xkb;
  xdg.configFile."sway".source = ./sway;
  # xdg.configFile."sway/config.d".source = ./sway/config.d;
  # xdg.configFile."sway/pingu_oldschool_bg.jpg".source = ./sway/pingu_oldschool_bg.jpg;
  xdg.configFile."nvim".source = ./nvim;
  xdg.configFile."waybar".source = ./waybar;
  # xdg.configFile."waybar/config.jsonc".source = ./sway/waybar/config.jsonc;
  # xdg.configFile."waybar/style.css".source = ./sway/waybar/style.css;
  # xdg.configFile."mako/config".source = ./sway/mako/config;

  # home.file."Pictures/background.jpg".source = ./sway/background.jpg;

  services.mako.enable = true;
  services.mako.package = pkgs.mako;
}

