{
  config,
  pkgs,
  nixpkgs,
  ...
}: {
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    auto-optimise-store = true;
  };

  nix.registry.nixpkgs.flake = nixpkgs;

  environment.systemPackages = with pkgs; [zsh-completions];

  fonts.fontDir.enable = true;
  fonts.fonts = with pkgs; [(nerdfonts.override {fonts = ["JetBrainsMono"];})];

  # Enables GnuPG agent for every user session.
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.zsh.enable = true;

  services.nix-daemon.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
