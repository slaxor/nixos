{
  description = "Slash's NixOS with Sway";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = { self, nixpkgs, home-manager, sops-nix, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      nixosConfigurations.kea = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/kea.nix
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          {
            # home-manager.useGlobalPkgs = true;
            # home-manager.users.slash = import ./home/slash.nix;
	    home-manager = {
		    useUserPackages = true;
		    useGlobalPkgs = true;
		    backupFileExtension = "backup";
  		    
		    users.slash = {
		      home.username = "slash";
		      home.homeDirectory = "/home/slash";
		      imports = [ 
		        sops-nix.homeManagerModules.sops
			./home/slash.nix 
		      ];
		    };
		  };
		}
        ];
      };
    };
}
