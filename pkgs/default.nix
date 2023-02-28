{ pkgs }:
with pkgs; {
  satisfactory-mod-manager = callPackage ./satisfactory-mod-manager.nix { };
}
