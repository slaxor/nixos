{
  description = "Slaxor's NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    slaxor-editor = {
      url = "git+https://codeberg.org/slaxor/editor";
    };

    slaxor-replace = {
      url = "git+https://codeberg.org/slaxor/replace";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      slaxor-editor,
      slaxor-replace,
      ...
    }@inputs:
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
            { nixpkgs.hostPlatform.system = "x86_64-linux"; }
            { nixpkgs.overlays = [ self.overlays.unstable ]; }
            ./modules/common-desktop.nix
            ./modules/users/stackit.nix
            ./hosts/kea.nix
            (
              { pkgs, ... }:
              {
                environment.systemPackages = [
                  slaxor-editor.packages.${pkgs.stdenv.hostPlatform.system}.default
                  slaxor-replace.packages.${pkgs.stdenv.hostPlatform.system}.default
                ];
              }
            )
          ];
        };

        taz = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            { nixpkgs.overlays = [ self.overlays.unstable ]; }
            ./modules/common-desktop.nix
            ./hosts/taz.nix
            (
              { pkgs, ... }:
              {
                environment.systemPackages = [
                  slaxor-editor.packages.${pkgs.stdenv.hostPlatform.system}.default
                  slaxor-replace.packages.${pkgs.stdenv.hostPlatform.system}.default
                ];
              }
            )
          ];
        };

        hare = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            { nixpkgs.overlays = [ self.overlays.unstable ]; }
            ./modules/common-server.nix
            ./hosts/hare.nix
            (
              { pkgs, ... }:
              {
                environment.systemPackages = [
                  slaxor-editor.packages.${pkgs.stdenv.hostPlatform.system}.default
                  slaxor-replace.packages.${pkgs.stdenv.hostPlatform.system}.default
                ];
              }
            )
          ];
        };
      };
    };
}
