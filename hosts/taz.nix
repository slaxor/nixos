{ config, pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  imports =
    [ # Include the results of the hardware scan.
      ./taz-hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = false;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    enableCryptodisk = true;
    device = "nodev";
  };

  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.networkmanager.enable = true;
  networking.hostName = "taz"; # Define your hostname.
  i18n.defaultLocale = "de_DE.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "altgr-intl";
    options = "eurosign:e";
  };

  users.groups.slash = {
    gid = 10000;
  };

  users.users.slash = {
    isNormalUser = true;
    extraGroups = [ "wheel" "dialout" "video" "audio" "input" ];
    shell = pkgs.bash;
    uid = 10000;
    group = "slash";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHgoR0SjvlG9RSXJYEKH6noGzXwA0vO5Jt8icqLf/wWk slash@turtle"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC1eYgW2UdnsTCk2zppw4yghgpHOhOllN3el1DuAk6Wc slash@taz"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA0vHE8aUjdAA+HcTNmXnwePICLIju63GmMqOADRSRY4 slash@mule"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF6IgO7XKpG2RNbw2TOu25E1ZsVrqZGK3saKXrrtTfQB slash@crocodile"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOtjkbH0TGABWHHuV5Rrzt0UIKJBkPIo8tHXHoyC9kBT slash@kea"
    ];
  };
  services.getty.autologinUser = "slash";

  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    age
    ctags
    curl
    docker
    fd
    foot
    fzf
    git
    gparted
    home-manager
    htop
    hyprpolkitagent
    iotop
    lf
    librewolf
    mc
    mtr
    neovim
    netcat
    plocate
    polkit
    ripgrep
    socat
    sops
    sway
    tmux
    tree
    wayland
    wget
  ];
  security.polkit.enable = true;
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };
  services.gnome.gnome-keyring.enable = true;
  # services.xserver.desktopManager.sway.enable = true;

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true; # so that gtk works properly
    extraPackages = with pkgs; [
      swaylock
      swayidle
      wl-clipboard
      wf-recorder
      mako # notification daemon
      grim
     #kanshi
      slurp
      alacritty # Alacritty is the default terminal in the config
      wofi
    ];
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export _JAVA_AWT_WM_NONREPARENTING=1
      export MOZ_ENABLE_WAYLAND=1

    '';
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  programs.waybar.enable = true;
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  # Graphics settings
  #services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.videoDrivers = [ "nouveau" ];

  hardware.graphics.enable32Bit = true;

  services.printing.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (
        subject.isInGroup("users")
          && (
            action.id == "org.freedesktop.login1.reboot" ||
            action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
            action.id == "org.freedesktop.login1.power-off" ||
            action.id == "org.freedesktop.login1.power-off-multiple-sessions"
          )
        )
      {
        return polkit.Result.YES;
      }
    });
    polkit.addRule(function(action, subject) {
        if (action.id == "org.gnome.gparted" &&
            subject.isInGroup("wheel")) {
            return polkit.Result.YES;
        }
    });
  '';
  systemd = {
    user.services.hyprpolkitagent = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
    };
  };
  
  services.locate.enable = true;
  services.locate.package = pkgs.plocate;
  programs.mtr.enable = true;
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${pkgs.sway}/bin/sway";
        user = "slash";
      };
      default_session = initial_session;
    };
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
