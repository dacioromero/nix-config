# Obsidian has a black screen on Wayland
# https://github.com/NixOS/nixpkgs/pull/196992
final: prev: {
  obsidian = prev.symlinkJoin {
    name = "obsidian";
    paths = [prev.obsidian];
    buildInputs = [prev.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/obsidian \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform=wayland}}"
    '';
  };
}
