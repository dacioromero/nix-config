{
  description = "Home Manager configuration of Dacio Romero";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    omni-alacritty = {
      url = "github:getomni/alacritty";
      flake = false;
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    darwin,
    flake-utils,
    ...
  }: let
    inherit (home-manager.lib) homeManagerConfiguration;
    inherit (darwin.lib) darwinSystem;
    inherit (flake-utils.lib) eachDefaultSystem;
    inherit (nixpkgs.lib) nixosSystem;
  in
    {
      homeConfigurations."dacio@firetower" = homeManagerConfiguration {
        pkgs = self.legacyPackages.x86_64-linux;
        modules = [./hosts/firetower/home.nix];
        extraSpecialArgs = {inherit inputs;};
      };

      homeConfigurations."dacio@firebook-pro.lan" = homeManagerConfiguration {
        pkgs = self.legacyPackages.aarch64-darwin;
        modules = [./hosts/firebook-pro/home.nix];
        extraSpecialArgs = {inherit inputs;};
      };

      darwinConfigurations."firebook-pro" = darwinSystem {
        system = "aarch64-darwin";
        modules = [./hosts/firebook-pro/darwin-configuration.nix];
        specialArgs = {inherit inputs;};
      };

      nixosConfigurations."firetower" = nixosSystem {
        system = "x86_64-linux";
        modules = [./hosts/firetower/configuration.nix];
        specialArgs = {inherit inputs;};
      };
    }
    // eachDefaultSystem (system: rec {
      legacyPackages = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [(import ./overlays/discord.nix)];
      };

      formatter = legacyPackages.alejandra;
    });
}
