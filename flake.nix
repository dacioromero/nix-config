{
  description = "Home Manager configuration of Dacio Romero";

  nixConfig = {
    extra-substituters = "https://cache.armv7l.xyz";
    extra-trusted-public-keys = "cache.armv7l.xyz-1:kBY/eGnBAYiqYfg0fy0inWhshUo+pGFM3Pj7kIkmlBk=";
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-22_11.url = "github:NixOS/nixpkgs/nixos-22.11";
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
    darwin,
    flake-utils,
    nixpkgs-22_11,
    ...
  }: let
    inherit (darwin.lib) darwinSystem;
    inherit (flake-utils.lib) eachDefaultSystem;
    inherit (nixpkgs.lib) nixosSystem;
  in
    rec {
      darwinConfigurations."firebook-pro" = darwinSystem {
        pkgs = self.legacyPackages.aarch64-darwin;
        system = "aarch64-darwin";
        modules = [./hosts/firebook-pro/darwin-configuration.nix];
        specialArgs = {inherit inputs;};
      };

      nixosConfigurations."firetower" = nixosSystem {
        system = "x86_64-linux";
        pkgs = self.legacyPackages.x86_64-linux;
        modules = [./hosts/firetower/configuration.nix];
        specialArgs = {inherit inputs;};
      };

      nixosConfigurations."firepad" = nixosSystem {
        system = "x86_64-linux";
        pkgs = self.legacyPackages.x86_64-linux;
        modules = [./hosts/firepad/configuration.nix];
        specialArgs = {inherit inputs;};
      };

      # Using stable instead of unstable do to compile error
      # https://github.com/containers/netavark/issues/578
      nixosConfigurations.firepi = nixpkgs-22_11.lib.nixosSystem {
        system = "armv7l-linux";
        modules = [
          ./hosts/firepi/configuration.nix
          # TODO: Find better way to allow building armv7l-linux from current platform
          {
            nixpkgs.buildPlatform = "x86_64-linux";
          }
        ];
        specialArgs = {inherit inputs;};
      };

      overlays = import ./overlays;
      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home-manager;
    }
    // eachDefaultSystem (system: rec {
      legacyPackages = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        config.firefox.enableGnomeExtensions = true;
        overlays = builtins.attrValues self.overlays;
      };

      formatter = legacyPackages.alejandra;
    });
}
