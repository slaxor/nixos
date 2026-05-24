{
  description = "Slaxor's NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
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
      nixpkgs-unstable,
      home-manager,
      slaxor-editor,
      slaxor-replace,
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };

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
        ./home/modules/neovim
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
        extraSpecialArgs = { inherit pkgs-unstable; };
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
      overlays.unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          system = prev.stdenv.hostPlatform.system;
          config.allowUnfree = true;
        };
      };

      nixosConfigurations = {
        kea = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            home-manager.nixosModules.home-manager
            { nixpkgs.hostPlatform.system = system; }
            {
              nixpkgs.overlays = [
                self.overlays.unstable
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
            slaxorPkgs
          ];
        };

        taz = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            {
              nixpkgs.overlays = [
                self.overlays.unstable
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
            slaxorPkgs
          ];
        };

        hare = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            home-manager.nixosModules.home-manager
            {
              nixpkgs.overlays = [
                self.overlays.unstable
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
            ./users/thorsten.nix
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
