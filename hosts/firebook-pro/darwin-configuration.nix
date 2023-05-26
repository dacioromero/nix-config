{ pkgs
, inputs
, ...
}:
let
  inherit (inputs) home-manager-stable self;
in
{
  imports =
    [ home-manager-stable.darwinModules.home-manager ]
    ++ (with self.nixosModules; [
      nix
      nixpkgs
      hm
    ]);

  # fcitx-engines is deprecated but referenced by home-manager (release-22.11)
  nixpkgs.overlays = [
    (final: prev: {
      fcitx-engines = {};
    })
  ];

  fonts.fontDir.enable = true;
  fonts.fonts = [ (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; }) ];

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

  home-manager.users.dacio = import ./home.nix;

  services.nix-daemon.enable = true;

  system.stateVersion = 4;
}
