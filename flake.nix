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
    # To add a new host:
    #   1. Create hosts/<hostname>/configuration.nix — import modules/common.nix + desired modules
    #   2. Create hosts/<hostname>/hardware.nix — boot loader, GPU, networking.hostId
    #   3. Create hosts/<hostname>/hardware-configuration.nix — from nixos-generate-config
    #   4. Create home/<hostname>.nix — import home/common.nix + host-specific programs
    #   5. Add a nixosConfigurations.<hostname> entry below
    nixosConfigurations.imac = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};
      modules = [
        ./hosts/imac/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.bkrishnan = import ./home/imac.nix;
        }
      ];
    };

    nixosConfigurations.mac-mini = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};
      modules = [
        ./hosts/mac-mini/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.bkrishnan = import ./home/mac-mini.nix;
        }
      ];
    };
  };
}
