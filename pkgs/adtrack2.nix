{ stdenv
, fetchurl
, autoPatchelfHook
, SDL
}: stdenv.mkDerivation rec {
  name = "adtrack2";
  version = "2.4.24";

  src = fetchurl {
    url = "http://www.adlibtracker.net/files/adtrack-${version}-linux-bin-debian-stretch-x86.tar.gz";
    sha256 = "sha256-/fuymuXalE0IKh0zMxUydFvfypKs6mfqvq4/9Ebsixc=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    SDL
  ];

  installPhase = ''
    install -Dm755 adtrack2 "$out/bin/adtrack2"
    install -Dm755 adtrack2.ini "$out/share/adtrack2/adtrack2.ini"
  '';
}
