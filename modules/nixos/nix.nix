{inputs, ...}: {
  nix.settings = {
    trusted-users = ["@wheel"];
    experimental-features = ["nix-command" "flakes"];
    auto-optimise-store = true;
  };

  nix.registry.nixpkgs.flake = inputs.self;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
}
