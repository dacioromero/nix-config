{ pkgs }:
let
  callPackage = pkgs.lib.callPackageWith pkgs;
in
with pkgs; {
  satisfactory-mod-manager = callPackage ./satisfactory-mod-manager.nix { };
  xwaylandvideobridge = callPackage ./xwaylandvideobridge.nix { };
}
