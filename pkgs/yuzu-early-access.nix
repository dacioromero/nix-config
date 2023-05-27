{ fetchzip
, runCommand
, gnutar
, fetchgit
, yuzu-early-access
}:
let
  version = "3617";
  distHash = "sha256:0s4vph87n3ydkq2snlydg6nrjd9jmxxzky095apfydb6zvcjjyfh";
  fullHash = "sha256:02gag1wqhffllx2vgq7akjim9b1n6g7pjmij11rm4w790hr3rw3h";

  eaZip = fetchzip {
    name = "yuzu-ea-windows-dist";
    url = "https://github.com/pineappleEA/pineapple-src/releases/download/EA-${version}/Windows-Yuzu-EA-${version}.zip";
    hash = distHash;
  };

  eaGitSrc = runCommand "yuzu-ea-dist-unpacked"
    {
      src = eaZip;
      nativeBuildInputs = [ gnutar ];
    }
    ''
      mkdir $out
      tar xf $src/*.tar.xz --directory=$out --strip-components=1
    '';

  eaSrcRehydrated = fetchgit {
    url = eaGitSrc;
    fetchSubmodules = true;
    hash = fullHash;
  };
in
yuzu-early-access.overrideAttrs (_oldAttrs: {
  inherit version;
  src = eaSrcRehydrated;
  preConfigure = ''
    cmakeFlagsArray+=(
      "-DTITLE_BAR_FORMAT_IDLE=yuzu | early-access ${version} (nixpkgs) {}"
      "-DTITLE_BAR_FORMAT_RUNNING=yuzu | early-access ${version} (nixpkgs) | {}"
    )
  '';
})
