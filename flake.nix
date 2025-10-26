{
  description = "Slash's NixOS with Sway";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    slaxor-editor = {
      url = "git+https://codeberg.org/slaxor/editor";
      # Optional: Make it use your system's nixpkgs version to save space
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, slaxor-editor, ... }@inputs: {
    overlays.unstable = final: prev: {
      unstable = import nixpkgs-unstable {
        system = prev.system;
        config.allowUnfree = true;
      };
    };
    nixosConfigurations = {
      kea = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          { nixpkgs.overlays = [ self.overlays.unstable ]; }
          ./hosts/kea.nix
        ];
      };

      taz = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          { nixpkgs.overlays = [ self.overlays.unstable ]; }
          ({ config, pkgs, ... }: {
            # B. Add the package to systemPackages
            environment.systemPackages = with pkgs; [
              # Access the package via the input name (slaxor-editor)
              slaxor-editor.packages.${pkgs.system}.default # Assuming it exposes a default package
              # OR if the package is named 'editor':
              # slaxor-editor.packages.${pkgs.system}.editor
            ];
          })
          ./hosts/taz.nix
        ];
      };
    };
  };
}

