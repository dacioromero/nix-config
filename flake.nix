{
  description = "Home Manager configuration of Dacio Romero";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
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
    omni-kitty = {
      url = "github:dacioromero/kitty";
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
        extraSpecialArgs = inputs;
      };

      homeConfigurations."dacio@firebook-pro.lan" = homeManagerConfiguration {
        pkgs = self.legacyPackages.aarch64-darwin;
        modules = [./hosts/firebook-pro/home.nix];
        extraSpecialArgs = inputs;
      };

      homeConfigurations."dacio@firepad" = homeManagerConfiguration {
        pkgs = self.legacyPackages.x86_64-linux;
        modules = [./hosts/firepad/home.nix];
        extraSpecialArgs = inputs;
      };

      darwinConfigurations."firebook-pro" = darwinSystem {
        system = "aarch64-darwin";
        modules = [./hosts/firebook-pro/darwin-configuration.nix];
        specialArgs = inputs;
      };

      nixosConfigurations."firetower" = nixosSystem {
        system = "x86_64-linux";
        modules = [./hosts/firetower/configuration.nix];
        specialArgs = inputs;
      };

      nixosConfigurations."firepad" = nixosSystem {
        system = "x86_64-linux";
        modules = [./hosts/firepad/configuration.nix];
        specialArgs = inputs;
      };

      overlays = import ./overlays;
      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home-manager;
    }
    // eachDefaultSystem (system: rec {
      legacyPackages = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = builtins.attrValues self.overlays;
      };

      formatter = legacyPackages.alejandra;
    });
}
