# Discord doesn't render properly on Wayland
# https://github.com/NixOS/nixpkgs/issues/159267
# https://github.com/corytertel/nix-configuration/blob/2502f7b2edd3efa358746335f21bbfdb6343c84f/overlays/discord.nix
final: prev:
let
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
    "--enable-gpu-compositing"
    "--enable-gpu-rasterization"
    "--enable-native-gpu-memory-buffers"
    "--ignore-gpu-blacklist"
  ];
in
rec {
  discord = prev.symlinkJoin {
    name = "discord";
    paths = [ (prev.discord.override { withOpenASAR = true; }) ];
    buildInputs = [ prev.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/discord \
        --add-flags "${commandLineArgs}"
      wrapProgram $out/bin/Discord \
        --add-flags "${commandLineArgs}"
    '';
  };

  discord-gpu = prev.symlinkJoin {
    name = "discord";
    paths = [ discord ];
    buildInputs = [ prev.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/discord \
        --add-flags "${gpuCommandLineArgs}"
      wrapProgram $out/bin/Discord \
        --add-flags "${gpuCommandLineArgs}"
    '';
  };
}
