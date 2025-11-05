{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs: {
    overlays.unstable = final: prev: {
      unstable = import nixpkgs-unstable {
        system = prev.system;
        config.allowUnfree = true;
      };
    };

    nixosConfigurations.taz = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; }; # Optional, but good practice

        modules = [
          self.overlays.unstable
          ./configuration.nix
          home-manager.nixosModules.home-manager
        ];
    };
  };
  imports = [ ./hosts/taz.nix ];
  nixpkgs = {
    config = {
      allowUnfree = true;
      packageOverrides = pkgs: {
        unstable = import <unstable> {
          config = config.nixpkgs.config;
        };
      };
    };
  }
}
