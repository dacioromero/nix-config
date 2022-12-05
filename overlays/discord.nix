# https://github.com/corytertel/nix-configuration/blob/2502f7b2edd3efa358746335f21bbfdb6343c84f/overlays/discord.nix
final: prev: let
  source = prev.discord.override {withOpenASAR = true;};

  commandLineArgs = toString [
    "--disable-features=UseOzonePlatform"
    "--enable-accelerated-mjpeg-decode"
    "--enable-accelerated-video"
    "--enable-features=VaapiVideoDecoder"
    "--enable-zero-copy"
    "--use-gl=desktop"
  ];

  # https://wiki.archlinux.org/title/Discord#Lagging_when_scrolling_through_your_guilds
  # https://bbs.archlinux.org/viewtopic.php?id=259998
  # https://github.com/flathub/com.discordapp.Discord/blob/5209984f01c1540b7f5ccd92e5e47794a22a1277/discord.sh#L9
  gpuCommandLineArgs = toString [
    "--disable-features=UseOzonePlatform"
    "--enable-accelerated-mjpeg-decode"
    "--enable-accelerated-video"
    "--enable-features=VaapiVideoDecoder"
    "--enable-gpu-compositing"
    "--enable-gpu-rasterization"
    "--enable-native-gpu-memory-buffers"
    "--enable-zero-copy"
    "--ignore-gpu-blacklist"
    "--use-gl=desktop"
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
