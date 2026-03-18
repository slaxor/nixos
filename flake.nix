{
  description = "Slaxors's NixOS with Sway";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    slaxor-editor = {
      url = "git+https://codeberg.org/slaxor/editor";
      inputs.nixpkgs.follows = "nixpkgs";
    };

		# slaxor-replace = {
			# url = "git+https://codeberg.org/slaxor/replace";
			# inputs.nixpkgs.follows = "nixpkgs";
			# flake = false;
		# };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      slaxor-editor,
      # slaxor-replace,
      ...
    }@inputs:
    {
      overlays.unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          system = prev.system;
          config.allowUnfree = true;
        };
      };
      nixosConfigurations = {
        kea = nixpkgs.lib.nixosSystem {
          system  = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            { nixpkgs.overlays = [ self.overlays.unstable ]; }
            ./modules/common-desktop.nix
            ./modules/users/stackit.nix
            ./hosts/kea.nix
            ({ pkgs, ... }: {
							environment.systemPackages = [
								slaxor-editor.packages.${pkgs.system}.default
								# slaxor-replace.packages.${pkgs.system}.default
							];
						})
          ];
        };

        taz = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            { nixpkgs.overlays = [ self.overlays.unstable ]; }
            ./modules/common-desktop.nix
            ./hosts/taz.nix
            ./hosts/users/slash.nix

            ({ pkgs, ... }: {
							environment.systemPackages = [
								slaxor-editor.packages.${pkgs.system}.default
								# slaxor-replace.packages.${pkgs.system}.default
							];
						})
          ];
        };

        hare = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            { nixpkgs.overlays = [ self.overlays.unstable ]; }
            ./modules/common-server.nix
            ./hosts/hare.nix
            # ({ config, pkgs, ... }: {
            # environment.systemPackages = with pkgs; [
            # slaxor-editor.packages.${pkgs.system}.default
            # ];
            # })
            # ({ config, pkgs, ... }: {
            # environment.systemPackages = with pkgs; [
            # slaxor-replace.packages.${pkgs.system}.default
            # ];
            # })
          ];
        };
      };
    };
}
