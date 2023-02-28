{ inputs
, pkgs
, lib
, ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
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

  nix.registry.nixpkgs.flake = inputs.nixpkgs;

  nix.gc = {
    automatic = true;
    # nix.gc.dates not implemented by nix-darwin
    # https://github.com/LnL7/nix-darwin/pull/490#issuecomment-1371785731
    dates = lib.mkIf (!isDarwin) "weekly";
    options = "--delete-older-than 30d";
  };
}
