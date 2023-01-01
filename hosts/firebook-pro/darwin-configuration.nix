{
  pkgs,
  nixpkgs,
  ...
}: {
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings.auto-optimise-store = true;
  nix.registry.nixpkgs.flake = nixpkgs;

  environment.systemPackages = with pkgs; [zsh-completions];

  fonts.fontDir.enable = true;
  fonts.fonts = with pkgs; [(nerdfonts.override {fonts = ["JetBrainsMono"];})];

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
