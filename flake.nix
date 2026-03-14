{
  description = "bkrishnan — NixOS flake (multi-host, Home Manager integrated)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: {
    # Each host maps to nixosConfigurations.<hostname>.
    # Add a new host by duplicating this block and pointing at hosts/<hostname>/hardware.nix.
    nixosConfigurations.imac = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.bkrishnan = import ./home.nix;
        }
      ];
    };
  };
}
