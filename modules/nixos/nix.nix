{ inputs
, pkgs
, lib
, ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  flakeInputs = lib.filterAttrs (_: input: input ? "_type" && input._type == "flake") inputs;
  sudoGroup =
    if isDarwin
    then "@admin"
    else "@wheel";
in
{
  nix.settings = {
    trusted-users = [ sudoGroup ];
    experimental-features = [ "nix-command" "flakes" ];
    # https://github.com/NixOS/nix/issues/7273
    auto-optimise-store = !isDarwin;
  };

  # Add inputs to registry and path for caching and consistency
  # https://github.com/jakelogemann/fnctl/blob/f5ddc7c88ae22579ce61d5201da92e90852cfce0/nix/lib/mkSystem.nix#L37-L40
  nix.registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
  nix.nixPath = lib.mapAttrsToList (name: flake: "${name}=${flake}") flakeInputs;

  nix.gc = {
    automatic = true;
    # nix.gc.dates not implemented by nix-darwin
    # https://github.com/LnL7/nix-darwin/pull/490#issuecomment-1371785731
    dates = lib.mkIf (!isDarwin) "weekly";
    options = "--delete-older-than 14d";
  };
}
