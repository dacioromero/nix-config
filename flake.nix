{
  description = "Home Manager configuration of Dacio Romero";

  nixConfig = {
    extra-substituters = [
      "https://cache.armv7l.xyz"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.armv7l.xyz-1:kBY/eGnBAYiqYfg0fy0inWhshUo+pGFM3Pj7kIkmlBk="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:NixOS/nixpkgs/15ac0abbe677a7c9e1f2a255bf93889701eabb06";
    nixpkgs-gfeeds-2_0_1.url = "github:dacioromero/nixpkgs/gfeeds-2.0.1";
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
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    omni-alacritty = {
      url = "github:getomni/alacritty";
      flake = false;
    };
    omni-kitty = {
      url = "github:dacioromero/kitty";
      flake = false;
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , darwin
    , flake-utils
    , pre-commit-hooks
    , ...
    } @ inputs:
    let
      inherit (darwin.lib) darwinSystem;
      inherit (flake-utils.lib) eachDefaultSystem;
      inherit (nixpkgs.lib) nixosSystem;
    in
    rec {
      darwinConfigurations."firebook-pro" = darwinSystem {
        system = "aarch64-darwin";
        modules = [ ./hosts/firebook-pro/darwin-configuration.nix ];
        specialArgs = { inherit inputs; };
      };

      nixosConfigurations."firetower" = nixosSystem {
        system = "x86_64-linux";
        modules = [ ./hosts/firetower/configuration.nix ];
        specialArgs = { inherit inputs; };
      };

      nixosConfigurations."firepad" = nixosSystem {
        system = "x86_64-linux";
        modules = [ ./hosts/firepad/configuration.nix ];
        specialArgs = { inherit inputs; };
      };

      nixosConfigurations.firepi = nixosSystem {
        system = "armv7l-linux";
        modules = [
          ./hosts/firepi/configuration.nix
          # TODO: Find better way to allow building armv7l-linux from current platform
          {
            nixpkgs.buildPlatform = "x86_64-linux";
          }
        ];
        specialArgs = { inherit inputs; };
      };

      overlays = import ./overlays;
      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home-manager;
    }
    // eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      formatter = pkgs.nixpkgs-fmt;
      packages = import ./pkgs { inherit pkgs; };
      checks.pre-commit-check = pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          nixpkgs-fmt.enable = true;
          deadnix.enable = true;
          statix.enable = true;
        };
        settings = {
          deadnix.edit = true;
          deadnix.noLambdaArg = true;
        };
      };
      devShell = pkgs.mkShell {
        inherit (self.checks.${system}.pre-commit-check) shellHook;
      };
    });
}
