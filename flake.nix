{
  description = "iMac 2012 NixOS Configuration";

  inputs = {
    # This locks your system to the 24.11 stable channel
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    # 'nixos' must match your hostname in configuration.nix
    nixosConfigurations.imac = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
      ];
    };
  };
}
