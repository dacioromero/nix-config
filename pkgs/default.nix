{ pkgs }:
let
  callPackage = pkgs.lib.callPackageWith pkgs;
in
with pkgs; {
  satisfactory-mod-manager = callPackage ./satisfactory-mod-manager.nix { };
  xwaylandvideobridge = callPackage ./xwaylandvideobridge.nix { };
  # https://nixos.wiki/wiki/NixOS_on_ARM#The_easiest_way
  ubootBananaPim2Zero = pkgs.pkgsCross.armv7l-hf-multiplatform.buildUBoot {
    defconfig = "bananapi_m2_zero_defconfig";
    extraMeta.platforms = [ "armv7l-linux" ];
    filesToInstall = [ "u-boot-sunxi-with-spl.bin" ];
  };
}
