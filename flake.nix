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
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    darwin,
    flake-utils,
    ...
  }: let
    inherit (home-manager.lib) homeManagerConfiguration;
    inherit (darwin.lib) darwinSystem;

    forAllSystems = nixpkgs.lib.genAttrs flake-utils.lib.defaultSystems;
    packagesFor = forAllSystems (system:
      import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      });
  in {
    homeConfigurations."dacio@firetower" = homeManagerConfiguration {
      pkgs = packagesFor.x86_64-linux;
      modules = [./hosts/firetower/home.nix];
    };

    homeConfigurations."dacio@firebook-pro.lan" = homeManagerConfiguration {
      pkgs = packagesFor.aarch64-darwin;
      modules = [./hosts/firebook-pro/home.nix];
    };

    darwinConfigurations."firebook-pro" = darwinSystem {
      system = "aarch64-darwin";
      modules = [./hosts/firebook-pro/darwin-configuration.nix];
    };
  };
}
