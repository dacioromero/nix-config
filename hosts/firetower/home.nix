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

  # # Force Wayland on apps like VSCode and Firefox
  # home.sessionVariables."NIXOS_OZONE_WL" = 1;

  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    discord
    duf
    element-desktop
    goverlay
    heroic
    lutris
    newsflash
    nil
    prismlauncher
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

  programs.mangohud.enable = true;
  programs.nix-index.enable = true;

  home.stateVersion = "22.05";
}
