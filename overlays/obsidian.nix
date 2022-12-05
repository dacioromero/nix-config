# Obsidian has a black screen on Wayland
# https://github.com/NixOS/nixpkgs/pull/196992
final: prev: let
  source = prev.obsidian;
  wrapped = prev.writeShellScriptBin "obsidian" ''
    exec ${source}/bin/obsidian --ozone-platform=wayland
  '';
in {
  obsidian = prev.symlinkJoin {
    name = "obsidian";
    paths = [
      wrapped
      source
    ];
  };
}
