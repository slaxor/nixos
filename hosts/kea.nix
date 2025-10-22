{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./kea-hardware-configuration.nix
      ../modules/base.nix
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

  # boot.initrd.luks.devices."luks-7c83c597-dc9d-452a-a573-18a221a24163".device = "/dev/disk/by-uuid/7c83c597-dc9d-452a-a573-18a221a24163";
  networking.hostName = "kea";
  networking.wireless.enable = true; 
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Berlin";
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
  '';

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
  ];


  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true; # if not already enabled
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    # (my prompt includes an urgency hint, so I want no sounds).
    extraConfig = {
      pipewire."99-silent-bell.conf" = {
        "context.properties" = {
          "module.x11.bell" = false;
        };
      };
    };
  };
  # services.pipewire.wireplumber.extraConfig."10-bluez" = {
  #   "monitor.bluez.properties" = {
  #     "bluez5.enable-sbc-xq" = true;
  #     "bluez5.enable-msbc" = true;
  #     "bluez5.enable-hw-volume" = true;
  #     "bluez5.roles" = [
  #       "hsp_hs"
  #       "hsp_ag"
  #       "hfp_hf"
  #       "hfp_ag"
  #     ];
  #   };
  # };
  services.pipewire.wireplumber.configPackages = [
    (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/10-bluez.conf" ''
      monitor.bluez.properties = {
        bluez5.enable-sbc-xq = true
        bluez5.enable-msbc = true
        bluez5.enable-hw-volume = true
        bluez5.roles = [hsp_hs hsp_ag hfp_hf hfp_ag]
      }
    '')
    (pkgs.writeTextDir "share/wireplumber/main.lua.d/99-alsa-lowlatency.lua" ''
      alsa_monitor.rules = {
        {
          matches = {{{ "node.name", "matches", "alsa_output.*" }}};
          apply_properties = {
            ["audio.format"] = "S32LE",
            ["audio.rate"] = "96000", -- for USB soundcards it should be twice your desired rate
            ["api.alsa.period-size"] = 2, -- defaults to 1024, tweak by trial-and-error
            -- ["api.alsa.disable-batch"] = true, -- generally, USB soundcards use the batch mode
          },
        },
      }
    '')
  ];
  # avahi required for service discovery
  services.avahi.enable = true;

  services.pipewire = {
    # opens UDP ports 6001-6002
    raopOpenFirewall = true;
  
    extraConfig.pipewire = {
      "10-airplay" = {
        "context.modules" = [
          {
            name = "libpipewire-module-raop-discover";
  
            # increase the buffer size if you get dropouts/glitches
            # args = {
            #   "raop.latency.ms" = 500;
            # };
          }
        ];
      };
    };
  };
  services.pipewire.extraConfig.pipewire."91-null-sinks" = {
    "context.objects" = [
      {
        # A default dummy driver. This handles nodes marked with the "node.always-driver"
        # properyty when no other driver is currently active. JACK clients need this.
        factory = "spa-node-factory";
        args = {
          "factory.name" = "support.node.driver";
          "node.name" = "Dummy-Driver";
          "priority.driver" = 8000;
        };
      }
      {
        factory = "adapter";
        args = {
          "factory.name" = "support.null-audio-sink";
          "node.name" = "Microphone-Proxy";
          "node.description" = "Microphone";
          "media.class" = "Audio/Source/Virtual";
          "audio.position" = "MONO";
        };
      }
      {
        factory = "adapter";
        args = {
          "factory.name" = "support.null-audio-sink";
          "node.name" = "Main-Output-Proxy";
          "node.description" = "Main Output";
          "media.class" = "Audio/Sink";
          "audio.position" = "FL,FR";
        };
      }
    ];
  };

  services.pipewire.extraConfig.pipewire."92-low-latency" = {
    "context.properties" = {
      "default.clock.rate" = 48000;
      "default.clock.quantum" = 32;
      "default.clock.min-quantum" = 32;
      "default.clock.max-quantum" = 32;
    };
  };
  services.pipewire.extraConfig.pipewire-pulse."92-low-latency" = {
    "context.properties" = [
      {
        name = "libpipewire-module-protocol-pulse";
        args = { };
      }
    ];
    "pulse.properties" = {
      "pulse.min.req" = "32/48000";
      "pulse.default.req" = "32/48000";
      "pulse.max.req" = "32/48000";
      "pulse.min.quantum" = "32/48000";
      "pulse.max.quantum" = "32/48000";
    };
    "stream.properties" = {
      "node.latency" = "32/48000";
      "resample.quality" = 1;
    };
  };
  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
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
  
  # Optional, hint Electron apps to use Wayland:
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # List services that you want to enable:

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.firewall.allowedUDPPorts = [ 53 68 ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;
  services.openssh.enable = true;
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
  environment.etc."mc/mc.ini".source = ./files/mc.ini;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}


