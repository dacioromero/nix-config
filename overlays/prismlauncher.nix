# https://github.com/PrismLauncher/PrismLauncher/issues/512
final: prev: let
  inherit (prev) lib;
  minecraft-wayland = prev.fetchFromGitHub {
    owner = "Admicos";
    repo = "minecraft-wayland";
    rev = "e4fb2a6f802b81f6398c328a4a271efe212a4955";
    sha256 = "sha256-P93555pYwI8uv7e9s5048XWYetAHg5Cyx3EeF8/rFsk=";
  };
  mcWaylandPatches =
    map (name: "${minecraft-wayland}/${name}")
    (lib.naturalSort (builtins.attrNames (lib.filterAttrs
      (name: type:
        type == "regular" && lib.hasSuffix ".patch" name)
      (builtins.readDir minecraft-wayland))));

  # libdecor = prev.libdecor.overrideAttrs (prevAttrs: rec {
  #   version = "0.1.1";

  #   src = prev.fetchFromGitLab {
  #     domain = "gitlab.freedesktop.org";
  #     owner = "libdecor";
  #     repo = "libdecor";
  #     rev = "3f3e5e1d9bc6401af5b788a283d55fa38410f483";
  #     sha256 = "sha256-ntU3g6ckqD6AbNUW/9J4OCP9gnLES2yskz9pQ+Jz97s=";
  #   };

  #   buildInputs = prevAttrs.buildInputs ++ [prev.gtk3];
  #   mesonFlags = [
  #     "-Dgtk=enabled"
  #   ];
  # });

  glfw = prev.glfw-wayland.overrideAttrs (prevAttrs: rec {
    version = "3.4.0";

    src = prev.fetchFromGitHub {
      owner = "glfw";
      repo = "glfw";
      rev = "87d5646f5d2bad0562744501633bf8105f59c193";
      sha256 = "sha256-P8izoGBCce65+CPAkGvb/qawiaWCpzwDWchRcAO1y9M=";
    };

    patches = mcWaylandPatches;
    # buildInputs = prevAttrs.buildInputs ++ [libdecor];
    buildInputs = prevAttrs.buildInputs ++ [prev.libdecor];
  });
in {
  prismlauncher = prev.prismlauncher.override {
    inherit glfw;
  };
}
