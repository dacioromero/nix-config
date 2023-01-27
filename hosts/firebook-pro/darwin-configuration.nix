{
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = with inputs; [
    home-manager.darwinModules.home-manager
    self.nixosModules.nix
  ];

  fonts.fontDir.enable = true;
  fonts.fonts = with pkgs; [(nerdfonts.override {fonts = ["JetBrainsMono"];})];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.zsh.enable = true;

  users.users.dacio = {
    description = "Dacio";
    home = "/Users/dacio";
    shell = pkgs.zsh;
    uid = 501;
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = {inherit inputs;};
  home-manager.users.dacio = import ./home.nix;

  services.nix-daemon.enable = true;

  system.stateVersion = 4;
}
