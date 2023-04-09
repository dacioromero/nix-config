final: prev: {
  # https://github.com/NixOS/nixpkgs/pull/225339
  sane-backends = prev.sane-backends.overrideAttrs (prevAttrs: {
    enableParallelInstalling = false;
  });
}
