{
  description = "Slash's NixOS with Sway";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs = { self, nixpkgs, ... }: {
    nixosConfigurations = {
      kea = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/kea.nix
        ];
      };

      taz = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/taz.nix
        ];
      };
    };
  };
}

