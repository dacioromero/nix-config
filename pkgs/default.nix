{ pkgs }:
let
  callPackage = pkgs.lib.callPackageWith pkgs;
  callPackage_i686 = pkgs.lib.callPackageWith pkgs.pkgsi686Linux;
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
  adtrack2 = callPackage_i686 ./adtrack2.nix { };
  # yuzu-early-access =
  #   let
  #     pname = "yuzu-early-access";
  #     version = "3610";
  #     src = pkgs.fetchurl {
  #       url = "https://github.com/pineappleEA/pineapple-src/releases/download/EA-${version}/Linux-Yuzu-EA-${version}.AppImage";
  #       sha256 = "sha256-hDGirhGrqRso+itYWHMnccP+F7vG4sKd5vnuYcLHB/c=";
  #     };

  #     appimageContents = appimageTools.extractType2 {
  #       inherit pname version src;
  #     };

  #   in
  #   pkgs.appimageTools.wrapType2 rec {
  #     inherit pname version src;

  #     extraInstallCommands = ''
  #       mv $out/bin/${pname}-${version} $out/bin/${pname}

  #       install -m 444 -D ${appimageContents}/org.yuzu_emu.yuzu.desktop $out/share/applications/${pname}.desktop
  #       install -m 444 -D ${appimageContents}/org.yuzu_emu.yuzu.svg $out/share/icons/hicolor/scalable/apps/${pname}.svg

  #       substituteInPlace $out/share/applications/${pname}.desktop \
  #         --replace 'Exec=yuzu %f' 'Exec=${pname} %f' \
  #         --replace 'TryExec=yuzu' 'TryExec=${pname}' \
  #         --replace 'Icon=org.yuzu_emu.yuzu' 'Icon=${pname}'
  #     '';

  #     extraPkgs = pkgs: with pkgs; [ qt5.qtbase ];
  #   };
  yuzu-early-access =
    let
      version = "3611";
      distHash = "sha256:1whwqb0p64x0nsnwr2rbl8n1974s7mil0mx62c8nam4v97v91dx3";
      fullHash = "sha256:0hqrx5s7f2r5q84bnvp4xqskwxx2sm4z1b2grkgpykcxmxr3hh3i";

      eaZip = pkgs.fetchzip {
        name = "yuzu-ea-windows-dist";
        url = "https://github.com/pineappleEA/pineapple-src/releases/download/EA-${version}/Windows-Yuzu-EA-${version}.zip";
        hash = distHash;
      };

      eaGitSrc = pkgs.runCommand "yuzu-ea-dist-unpacked"
        {
          src = eaZip;
          nativeBuildInputs = [ pkgs.gnutar ];
        }
        ''
          mkdir $out
          tar xf $src/*.tar.xz --directory=$out --strip-components=1
        '';

      eaSrcRehydrated = pkgs.fetchgit {
        url = eaGitSrc;
        fetchSubmodules = true;
        hash = fullHash;
      };
    in
    pkgs.yuzu-early-access.overrideAttrs (_oldAttrs: {
      inherit version;
      src = eaSrcRehydrated;
      preConfigure = ''
        cmakeFlagsArray+=(
          "-DTITLE_BAR_FORMAT_IDLE=yuzu | early-access ${version} (nixpkgs) {}"
          "-DTITLE_BAR_FORMAT_RUNNING=yuzu | early-access ${version} (nixpkgs) | {}"
        )
      '';
    });
}
