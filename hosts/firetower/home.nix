{ pkgs
, inputs
, ...
}: {
  imports = with inputs.self.homeManagerModules; [
    home
    wezterm
    linux
    kde
  ];

  # Force Wayland on apps like VSCode and Firefox
  home.sessionVariables."NIXOS_OZONE_WL" = 1;

  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    discord
    element-desktop
    gnome-feeds
    goverlay
    lsp-plugins # Plugins for EasyEffects
    newsflash
    prismlauncher
    protonup-qt
    psst
    qbittorrent
    satisfactory-mod-manager
    vkBasalt
  ];

  # Needed for Nerd Fonts to be found
  fonts.fontconfig.enable = true;

  # Microphone filters (noise gate)
  services.easyeffects.enable = true;
  services.syncthing.enable = true;

  programs.mangohud.enable = true;
  # programs.mangohud.enableSessionWide = true;
  programs.nix-index.enable = true;

  home.stateVersion = "22.05";
}
