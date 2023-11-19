{
  description = "NixOS configurations by Dacio Romero";

  nixConfig = {
    extra-substituters = [
      "https://cache.armv7l.xyz"
      "https://nix-community.cachix.org"
      "https://pre-commit-hooks.cachix.org"
      "https://crane.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.armv7l.xyz-1:kBY/eGnBAYiqYfg0fy0inWhshUo+pGFM3Pj7kIkmlBk="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "pre-commit-hooks.cachix.org-1:Pkk3Panw5AW24TOv6kz3PvLhlH8puAsJTBbOPmBo7Rc="
      "crane.cachix.org-1:8Scfpmn9w+hGdXH/Q9tTLiYAE/2dnJYRJP7kl80GuRk="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.flake-compat.follows = "flake-compat";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.3.0";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pre-commit-hooks-nix.follows = "pre-commit-hooks";
      inputs.flake-utils.follows = "flake-utils";
      inputs.rust-overlay.follows = "rust-overlay";
      inputs.flake-compat.follows = "flake-compat";
    };
    # Not used directly, for bumping version used by lanzaboote
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    # Not used directly, for de-duping w/ other dependencies
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.darwin.follows = "nix-darwin";
      inputs.home-manager.follows = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
      inputs.flake-compat.follows = "flake-compat";
    };
  };

  outputs =
    { self
    , nixpkgs
    , nix-darwin
    , flake-utils
    , pre-commit-hooks
    , deploy-rs
    , ...
    } @ inputs:
    let
      inherit (nix-darwin.lib) darwinSystem;
      inherit (flake-utils.lib) eachDefaultSystem;
      inherit (nixpkgs.lib) nixosSystem;
    in
    {
      deploy = {
        sshUser = "dacio";
        user = "root";
        # https://github.com/serokell/deploy-rs/issues/78
        sshOpts = [ "-t" ];
        magicRollback = false;
      };

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

      nixosConfigurations."firerelay" = nixosSystem {
        system = "x86_64-linux";
        modules = [ ./hosts/firerelay/configuration.nix ];
        specialArgs = { inherit inputs; };
      };
      deploy.nodes."firerelay" = {
        hostname = "firerelay.lan";
        profiles.system = {
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations."firerelay";
        };
      };

      nixosConfigurations."fiyarr" = nixosSystem {
        system = "x86_64-linux";
        modules = [ ./hosts/fiyarr/configuration.nix ];
        specialArgs = { inherit inputs; };
      };
      deploy.nodes."fiyarr" = {
        hostname = "fiyarr.lan";
        profiles.system = {
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations."fiyarr";
        };
      };

      nixosConfigurations."fiyarr-qbt" = nixosSystem {
        system = "x86_64-linux";
        modules = [ ./hosts/fiyarr-qbt/configuration.nix ];
        specialArgs = { inherit inputs; };
      };
      deploy.nodes."fiyarr-qbt" = {
        hostname = "fiyarr-qbt.lan";
        profiles.system = {
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations."fiyarr-qbt";
        };
      };

      overlays = import ./overlays;
      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home-manager;
      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
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
