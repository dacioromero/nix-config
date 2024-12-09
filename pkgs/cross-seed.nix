{ buildNpmPackage
, fetchFromGitHub
}: buildNpmPackage rec {
  pname = "cross-seed";
  version = "6.1.1";

  src = fetchFromGitHub {
    owner = "cross-seed";
    repo = "cross-seed";
    rev = "v${version}";
    hash = "sha256-d6hOk4iycsw8L6+K36MTFJiA1v5VrlIcP/fv2FxfbjE=";
  };

  npmDepsHash = "sha256-Kpv0yruxkHOiF031EVs7Lmz7ztjuDpVZjzsw34ukwqk=";
}
