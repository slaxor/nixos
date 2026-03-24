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
            ./hosts/kea
            ./users/slash.nix
            ./users/stackit.nix
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
            ./hosts/taz
            ./users/slash.nix
            ./users/stackit.nix
            ./modules/common-desktop.nix
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
            ./hosts/hare
            ./users/slash.nix
            ./users/thorsten.nix
            ./modules/common-server.nix
            ./modules/podman
            ./modules/kubernetes
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
