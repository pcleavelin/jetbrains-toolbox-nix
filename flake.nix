{
  description = "My NixOS Configuration";

  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-22.05"; };
  };

  outputs = { self, nixpkgs }@inputs: {
    nixosConfigurations.nixos-framework = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./configuration.nix ];
      specialArgs = { inherit inputs; };
    };
  };
}
