{
  inputs,
  pkgs,
  lib,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in {
  nix.settings = {
    trusted-users = ["@wheel"];
    experimental-features = ["nix-command" "flakes"];
    auto-optimise-store = true;
  };

  nix.registry.nixpkgs.flake = inputs.self;

  nix.gc = {
    automatic = true;
    # nix.gc.dates not implemented by nix-darwin
    # https://github.com/LnL7/nix-darwin/pull/490#issuecomment-1371785731
    dates = lib.mkIf (!isDarwin) "weekly";
    options = "--delete-older-than 30d";
  };
}
