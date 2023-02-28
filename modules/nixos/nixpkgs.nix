{
  inputs,
  config,
  ...
}: let
  inherit (inputs) self nixpkgs-gfeeds-2_0_1;
  inherit (config.nixpkgs) system;
in {
  nixpkgs = {
    config.allowUnfree = true;
    overlays =
      (builtins.attrValues self.overlays)
      ++ [
        (final: prev:
          {
            inherit (nixpkgs-gfeeds-2_0_1.legacyPackages.${system}) gnome-feeds;
          }
          // import ../../pkgs {pkgs = prev;})
      ];
  };
}
