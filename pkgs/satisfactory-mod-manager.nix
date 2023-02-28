{ mkYarnPackage
, fetchFromGitHub
, electron
, makeWrapper
, python3
, nodejs
, makeDesktopItem
, lib
, copyDesktopItems
,
}:
mkYarnPackage rec {
  pname = "SatisfactoryModManager";
  version = "2.9.3";

  src = fetchFromGitHub {
    owner = "satisfactorymodding";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-0JvjUzu/cKxoBafHHB3gmTpTO794NjPDQzp5ALTl/Do=";
  };

  # Make node-gyp work
  # https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/javascript.section.md#pitfalls-javascript-yarn2nix-pitfalls
  yarnPreBuild = ''
    mkdir -p $HOME/.node-gyp/${nodejs.version}
    echo 9 > $HOME/.node-gyp/${nodejs.version}/installVersion
    ln -sfv ${nodejs}/include $HOME/.node-gyp/${nodejs.version}
    export npm_config_nodedir=${nodejs}
  '';

  # platform-folders needs to be built for build
  pkgConfig = {
    "platform-folders" = {
      nativeBuildInputs = [
        python3
        nodejs
      ];
      postInstall = ''
        yarn --offline run install
      '';
    };
  };

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ];

  buildPhase = ''
    runHook preBuild
    export HOME=$(mktemp -d)
    pushd deps/satisfactory-mod-manager-gui
    rm node_modules
    ln -s ../../node_modules .
    yarn build
    popd
    runHook postBuild
  '';

  postInstall =
    let
      deps = "$out/libexec/satisfactory-mod-manager-gui/deps/satisfactory-mod-manager-gui";
    in
    ''
      for size in 16 32 64 128 256 512; do
        install -Dm644 ${deps}/icons/"$size"x"$size".png \
          $out/share/icons/hicolor/"$size"x"$size"/apps/SatisfactoryModManager.png
      done

      makeWrapper ${electron}/bin/electron $out/bin/SatisfactoryModManager \
        --inherit-argv0 \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}" \
        --add-flags "${deps}"
    '';

  dontStrip = true;
  doDist = false;

  desktopItems = [
    (makeDesktopItem {
      name = meta.mainProgram;
      exec = meta.mainProgram;
      icon = meta.mainProgram;
      desktopName = "Satisfactory Mod Manager";
      genericName = "Satisfactory Mod Manager";
      comment = meta.description;
      type = "Application";
      categories = [ "Game" ];
    })
  ];

  meta = with lib; {
    mainProgram = "SatisfactoryModManager";
    description = "Satisfactory mod and mod loader manager";
    homepage = "https://github.com/satisfactorymodding/SatisfactoryModManager";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
