{ pkgs
, inputs
, ...
}:
let
  inherit (inputs) home-manager self;
in
{
  imports =
    [ home-manager.darwinModules.home-manager ]
    ++ (with self.nixosModules; [
      nix
      nixpkgs
      hm
    ]);

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
