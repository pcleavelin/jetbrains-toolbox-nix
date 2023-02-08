{
  description = "My NixOS Configuration";

  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-unstable"; };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # jetbrains-toolbox.url = "./jetbrains-toolbox";
    # lapce.url = "./lapce";
    # ultorg.url = "./ultorg";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.nixos-framework = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./configuration.nix ];
      specialArgs = { inherit inputs; };
    };

    packages.x86_64-linux = {
      iso = inputs.nixos-generators.nixosGenerate {
        system = "x86_64-linux";
        modules = [ ./configuration.nix ];
        specialArgs = { inherit inputs; };
        format = "iso";
      };
    };
  };
}
