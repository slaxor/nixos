{
  description = "Slaxor's NixOS";

  inputs = {
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
    slaxor-editor.url = "git+https://codeberg.org/slaxor/editor";
    slaxor-replace.url = "git+https://codeberg.org/slaxor/replace";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      slaxor-editor,
      slaxor-replace,
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
        # ./home/modules/neovim
        ./home/modules/nixvim
        ./home/modules/shell
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
          ];
        };

    in
    {
      nixosConfigurations = {
        kea = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            home-manager.nixosModules.home-manager
            { nixpkgs.hostPlatform.system = system; }
            {
              nixpkgs.overlays = [
                inputs.nur.overlays.default
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
          ];
        };

        taz = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
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
          ];
        };

        hare = nixpkgs.lib.nixosSystem {
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
          ];
        };
      };
    };
}
