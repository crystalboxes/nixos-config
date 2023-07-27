{
  description = "my nix os config";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";

      # We want to use the same set of nixpkgs as our system.
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, home-manager, ... }: {
    nixosConfigurations.main = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        # TODO: Add overlays?
        ./hardware.nix
        ./vm.nix
        ./user/user.nix
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.snowbear = import ./user/home-manager.nix;
        }
      ];
    };
  };
}
