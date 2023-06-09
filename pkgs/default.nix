{ pkgs }:
let
  callPackage = pkgs.lib.callPackageWith pkgs;
  callPackage_i686 = pkgs.lib.callPackageWith pkgs.pkgsi686Linux;
in
{
  satisfactory-mod-manager = callPackage ./satisfactory-mod-manager.nix { };
  xwaylandvideobridge = callPackage ./xwaylandvideobridge.nix { };
  # https://nixos.wiki/wiki/NixOS_on_ARM#The_easiest_way
  ubootBananaPim2Zero = pkgs.pkgsCross.armv7l-hf-multiplatform.buildUBoot {
    defconfig = "bananapi_m2_zero_defconfig";
    extraMeta.platforms = [ "armv7l-linux" ];
    filesToInstall = [ "u-boot-sunxi-with-spl.bin" ];
  };
  adtrack2 = callPackage_i686 ./adtrack2.nix { };
}
