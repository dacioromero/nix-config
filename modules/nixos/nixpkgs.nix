{ inputs, ... }:
let
  inherit (inputs) self nixpkgs-unstable;
in
{
  nixpkgs = {
    config.allowUnfree = true;
    overlays =
      (builtins.attrValues self.overlays)
      ++ [
        (final: prev: import ../../pkgs { pkgs = prev; })
        (final: prev: { unstable = nixpkgs-unstable.legacyPackages.${prev.system}; })
      ];
  };
}
