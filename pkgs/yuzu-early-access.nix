{ fetchzip
, runCommand
, gnutar
, fetchgit
, yuzu-early-access
}:
let
  version = "3621";
  distHash = "sha256:0p8rxpwn9f269008skj7dy6qinpax93jhp33769akrprbh7f22if";
  fullHash = "sha256:1ph8frqifk42ypa0fw604k1z4kjisl35cai830cg4zhvd0vv7rn5";

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
