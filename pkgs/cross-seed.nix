{ buildNpmPackage
, fetchFromGitHub
}: buildNpmPackage rec {
  pname = "cross-seed";
  version = "5.9.2";

  src = fetchFromGitHub {
    owner = "cross-seed";
    repo = "cross-seed";
    rev = "v${version}";
    hash = "sha256-E0AlsFV9RP01YVwjw6ZQ8Lf1IVyuudxrb5oJ61EfIyo=";
  };

  npmDepsHash = "sha256-hZKLv+bzRFiMjNemydCUC1d7xul7Mm+vOPtCUD7p9XQ=";
}
