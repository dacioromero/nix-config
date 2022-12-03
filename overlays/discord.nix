# https://github.com/corytertel/nix-configuration/blob/2502f7b2edd3efa358746335f21bbfdb6343c84f/overlays/discord.nix
final: prev: let
  source = prev.discord.override {withOpenASAR = true;};

  # TODO: Comb over args
  commandLineArgs = toString [
    "--enable-accelerated-mjpeg-decode"
    "--enable-accelerated-video"
    "--enable-zero-copy"
    "--use-gl=desktop"
    "--disable-features=UseOzonePlatform"
    "--enable-features=VaapiVideoDecoder"
  ];

  gpuCommandLineArgs = toString [
    "--enable-accelerated-mjpeg-decode"
    "--enable-accelerated-video"
    "--ignore-gpu-blacklist"
    "--enable-native-gpu-memory-buffers"
    "--enable-gpu-rasterization"
    "--enable-zero-copy"
    "--use-gl=desktop"
    "--disable-features=UseOzonePlatform"
    "--enable-features=VaapiVideoDecoder"
  ];
in {
  discord = let
    wrapped = prev.writeShellScriptBin "discord" ''
      exec ${source}/bin/discord ${commandLineArgs}
    '';

    wrapped' = prev.writeShellScriptBin "Discord" ''
      exec ${source}/bin/Discord ${commandLineArgs}
    '';
  in
    prev.symlinkJoin {
      name = "discord";
      paths = [
        wrapped
        wrapped'
        source
      ];
    };

  discord-gpu = let
    wrapped = prev.writeShellScriptBin "discord" ''
      exec ${source}/bin/discord ${gpuCommandLineArgs}
    '';

    wrapped' = prev.writeShellScriptBin "Discord" ''
      exec ${source}/bin/Discord ${gpuCommandLineArgs}
    '';
  in
    prev.symlinkJoin {
      name = "discord";
      paths = [
        wrapped
        wrapped'
        source
      ];
    };
}
