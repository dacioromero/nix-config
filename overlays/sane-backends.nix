final: prev: {
  # Update to 1.2.1 broke searching for scanners
  sane-backends = prev.sane-backends.overrideAttrs (prevAttrs: {
    version = "1.1.1";
    src = prev.fetchurl {
      url = "https://gitlab.com/sane-project/backends/uploads/7d30fab4e115029d91027b6a58d64b43/sane-backends-1.1.1.tar.gz";
      sha256 = "sha256-3UsEw3pC8UxGGejupqlX9MfGF/5Z4yrihys3OUCotgM=";
    };
  });
}
