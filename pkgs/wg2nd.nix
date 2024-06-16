{ stdenv
, fetchurl
, libcap
}: stdenv.mkDerivation (finalAttrs: {
  name = "wg2nd";
  version = "0.2.1";

  src = fetchurl {
    url = "https://git.flu0r1ne.net/wg2nd/snapshot/wg2nd-${finalAttrs.version}.tar.xz";
    sha256 = "sha256-AyHqQQpGb5BGSmDnavmLHuOsqWClKe4AdZr+d3+7jIA=";
  };

  buildInputs = [ libcap ];

  makeFlags = [ "DESTDIR=" "PREFIX=$(out)" ];
})
