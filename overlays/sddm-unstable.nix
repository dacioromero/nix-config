final: prev: rec {
  # https://github.com/NixOS/nixpkgs/issues/233965#issuecomment-1562653655
  libsForQt5 = prev.libsForQt5.overrideScope' (qt5final: qt5prev: {
    sddm = qt5prev.sddm.overrideAttrs (oldAttrs: {
      pname = oldAttrs.pname + "-unstable";
      version = "unstable-2023-06-02";
      src = prev.fetchFromGitHub {
        owner = "sddm";
        repo = "sddm";
        rev = "9a07cf0fb095cf81771b56f513ec1dd126d0a1f2";
        sha256 = "sha256-iwVjFCg3Hmm5zhlfakLILA/QD8y3geWmyh4EOwgyiMA=";
      };

      patches = builtins.filter (prev.lib.hasSuffix "sddm-ignore-config-mtime.patch") oldAttrs.patches;

      nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ prev.docutils ];

      cmakeFlags = oldAttrs.cmakeFlags ++ [
        "-DBUILD_MAN_PAGES=ON"
        "-DSYSTEMD_TMPFILES_DIR=${placeholder "out"}/etc/tmpfiles.d"
        "-DSYSTEMD_SYSUSERS_DIR=${placeholder "out"}/lib/sysusers.d"
      ];

      outputs = (oldAttrs.outputs or [ "out" ]) ++ [ "man" ];
    });
  });

  inherit (libsForQt5) sddm;
}
