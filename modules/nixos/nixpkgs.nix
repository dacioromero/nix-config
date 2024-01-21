{ inputs, lib, pkgs, ... }:
let
  inherit (inputs) self;
in
{
  nixpkgs = {
    config.allowUnfree = true;
    # Obsidian uses outdated Electron version
    # https://github.com/NixOS/nixpkgs/issues/273611
    config.permittedInsecurePackages = lib.optional (pkgs.obsidian.version == "1.5.3") "electron-25.9.0";
    overlays =
      (builtins.attrValues self.overlays)
      ++ [ (final: prev: import ../../pkgs { pkgs = prev; }) ];
  };
}
