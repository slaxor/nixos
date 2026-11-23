{
  description = "Slaxor's NixOS";

  inputs = {
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fterm.url = "github:slaxor/fterm";
    ppk2_tool.url = "github:slaxor/ppk2_tool";
    slaxor-editor.url = "github:slaxor/editor";
    slaxor-replace.url = "github:slaxor/replace";
    slaxor-templates = {
      url = "github:slaxor/templates";
      flake = false;
    };

    craft-nix.url = "github:slaxor/craft-nix";
    kai = {
      url = "github:slaxor/Kai/enable_nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      slaxor-editor,
      slaxor-replace,
      craft-nix,
      fterm,
      ppk2_tool,
      kai,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      identity = {
        me.identity = {
          name = "Sascha Teske";
          email = "sascha.teske@microprojects.de";
          unixuser = "slash";
          netuser = "slaxor";
        };
      };

      hmBase = [
        ./home
        identity
        ./home/modules/users/slash.nix
        ./home/modules/base
        ./home/modules/git
        ./home/modules/gpg.nix
        ./home/modules/lf.nix
        ./home/modules/nixvim
        ./home/modules/shell
        craft-nix.homeModules.default
        fterm.homeModules.default
        ppk2_tool.homeManagerModules.default
        ./home/modules/ssh.nix
        ./home/modules/tmux
        ./home/modules/yazi
      ];

      mkHmUser =
        { role, host }:
        {
          imports = hmBase ++ [
            ./home/roles/${role}.nix
            ./home/hosts/${host}.nix
          ];
        };

      hmShared = {
        useGlobalPkgs = true;
        useUserPackages = true;
      };

      slaxorPkgs =
        { pkgs, ... }:
        {
          environment.systemPackages = [
            slaxor-editor.packages.${pkgs.stdenv.hostPlatform.system}.default
            slaxor-replace.packages.${pkgs.stdenv.hostPlatform.system}.default
            (pkgs.writeShellApplication {
              name = "mkprj";
              runtimeInputs = with pkgs; [
                nix
                git
                direnv
                jq
              ];
              text = builtins.readFile "${inputs.slaxor-templates}/mkprj.sh";
            })
          ];
        };
      nixIndex = {
        imports = [
          inputs.nix-index-database.nixosModules.nix-index
          inputs.ppk2_tool.nixosModules.default

        ];
        programs.command-not-found.enable = false;
        programs.nix-index-database.comma.enable = true;
      };

      hareModules = [
        home-manager.nixosModules.home-manager
        {
          nixpkgs.overlays = [
            inputs.nur.overlays.default
          ];
        }
        {
          home-manager = hmShared // {
            users.slash = mkHmUser {
              role = "server";
              host = "hare";
            };
          };
        }
        ./hosts/hare
        ./users/ming.nix
        ./users/slash.nix
        ./users/eggert.nix
        ./modules/common-server.nix
        ./modules/podman
        ./modules/kubernetes
        inputs.sops-nix.nixosModules.sops
        slaxorPkgs
        nixIndex
      ];

      mkInstaller =
        { platform, image }:
        nixpkgs.lib.nixosSystem {
          modules = [
            "${nixpkgs}/nixos/modules/installer/${image}"
            ./modules/installer.nix
            { nixpkgs.hostPlatform = platform; }
          ];
        };

    in
    {
      packages.x86_64-linux.installer-iso = self.nixosConfigurations.installer.config.system.build.isoImage;
      packages.aarch64-linux.installer-sd = self.nixosConfigurations.installer-sd.config.system.build.sdImage;

      nixosConfigurations = {
        kea = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            home-manager.nixosModules.home-manager
            { nixpkgs.hostPlatform.system = system; }
            {
              nixpkgs.overlays = [
                inputs.nur.overlays.default
                inputs.kai.overlays.default
              ];
            }
            {
              home-manager = hmShared // {
                users.slash = mkHmUser {
                  role = "desktop";
                  host = "kea";
                };
              };
            }
            ./modules/common-desktop.nix
            ./modules/laptop.nix
            ./hosts/kea
            ./users/slash.nix
            inputs.sops-nix.nixosModules.sops
            slaxorPkgs
            nixIndex
          ];
        };

        taz = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            home-manager.nixosModules.home-manager
            {
              nixpkgs.overlays = [
                inputs.nur.overlays.default
              ];
            }
            {
              home-manager = hmShared // {
                users.slash = mkHmUser {
                  role = "desktop";
                  host = "taz";
                };
              };
            }
            ./modules/common-desktop.nix
            ./modules/laptop.nix
            ./hosts/taz
            ./users/slash.nix
            inputs.sops-nix.nixosModules.sops
            slaxorPkgs
            nixIndex
          ];
        };

        raven = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            home-manager.nixosModules.home-manager
            inputs.disko.nixosModules.disko
            inputs.sops-nix.nixosModules.sops
            { nixpkgs.hostPlatform.system = system; }
            {
              nixpkgs.overlays = [
                inputs.nur.overlays.default
              ];
            }
            {
              home-manager = hmShared // {
                users.slash = mkHmUser {
                  role = "plasma";
                  host = "raven";
                };
              };
            }
            ./modules/common-plasma.nix
            ./modules/laptop.nix
            ./hosts/raven
            ./users/slash.nix
            ./users/rita.nix
            slaxorPkgs
            nixIndex
          ];
        };

        hare = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = hareModules;
        };

        hare-bubble = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = hareModules ++ [ ./hosts/hare-bubble ];
        };

        installer = mkInstaller {
          platform = "x86_64-linux";
          image = "cd-dvd/installation-cd-minimal.nix";
        };

        installer-sd = mkInstaller {
          platform = "aarch64-linux";
          image = "sd-card/sd-image-aarch64-installer.nix";
        };
      };
    };
}
