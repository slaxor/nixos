{ config, pkgs, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  imports = [
    ./kea-hardware-configuration.nix
    ../modules/system.nix
    ../modules/libvirt.nix
    ../modules/users/slash.nix
  ];

  boot = {
    loader = {
      systemd-boot.enable = false;
      grub = {
        enable = true;
        efiSupport = true;
        enableCryptodisk = true;
        device = "nodev";
      };
      efi.canTouchEfiVariables = true;
    };
    # Use latest kernel.
    kernelPackages = pkgs.linuxPackages_latest;
    initrd.kernelModules = [ "amdgpu" ];
  };


  networking = {
    networkmanager.enable = true;
    hostName = "kea";
    firewall = {
      allowedTCPPorts = [ 22 ];
      # allowedUDPPorts = [ ... ];
      # enable = false;
    };
  };

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

  security.polkit.enable = true;
  console = {
    font = "solar24x23";
    keyMap = "us";
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  programs = {
    mtr.enable = true;
    neovim = {
      enable = true;
      defaultEditor = true;
    };
    sway = {
      enable = true;
      wrapperFeatures.gtk = true; # so that gtk works properly
      extraPackages = with pkgs; [
        swaylock
        swayidle
        wl-clipboard
        wf-recorder
        mako # notification daemon
        grim
        kanshi
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
  };

  services = {
    # gnome.gnome-keyring.enable = true;
    openssh.enable = true;
    printing.enable = true;
    greetd = {
      enable = true;
      settings = rec {
        initial_session = {
          command = "${pkgs.sway}/bin/sway";
          user = "slash";
        };
        default_session = initial_session;
      };
    };

    locate = {
      enable = true;
      package = pkgs.plocate;
    };

    xserver = {
#       desktopManager.sway.enable = true;
      videoDrivers = [ "amdgpu" ];
      xkb = {
        layout = "us";
        variant = "altgr-intl";
        options = "eurosign:e";
      };
    };
    libinput.enable = true; # Enable touchpad support (enabled default in most desktopManager)
  };

  hardware.graphics.enable32Bit = true;



  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  security.polkit = {
    extraConfig = ''
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
  };

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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
