{ pkgs
, inputs
, ...
}: {
  imports = with inputs.self.homeManagerModules; [
    home
    wezterm
    linux
    kde
    easyeffects
  ];

  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    discord
    duf
    element-desktop
    goverlay
    heroic
    lutris
    mission-center
    ncdu
    newsflash
    nil
    prismlauncher
    protontricks
    qbittorrent
    r2modman
    spotify
    vkBasalt
    vlc
  ];

  # Needed for Nerd Fonts to be found
  fonts.fontconfig.enable = true;

  services.syncthing.enable = true;

  programs.obs-studio.enable = true;
  programs.obs-studio.plugins = with pkgs.obs-studio-plugins; [
    obs-vaapi
    obs-vkcapture
  ];

  programs.git.package = pkgs.gitFull;
  programs.git.extraConfig.sendemail = {
    smtpserver = "smtp.gmail.com";
    smtpuser = "dacioromero@gmail.com";
    smtpencryption = "ssl";
    smtpserverport = 465;
  };

  programs.mangohud.enable = true;
  programs.nix-index.enable = true;

  home.stateVersion = "22.05";
}
