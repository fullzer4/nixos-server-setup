{
  description = "NixOS Server Configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      
      fullzer4labs = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./modules/common.nix
          ./modules/monitoring.nix
          ./modules/auto-update.nix
          
          ./hosts/fullzer4labs/configuration.nix
          ./hosts/fullzer4labs/hardware-configuration.nix
        ];
      };

    };
  };
}
