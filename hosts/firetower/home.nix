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

  # # Force Wayland on apps like VSCode and Firefox
  # home.sessionVariables."NIXOS_OZONE_WL" = 1;

  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    comma
    discord
    duf
    element-desktop
    goverlay
    lsp-plugins # Plugins for EasyEffects
    newsflash
    nil
    prismlauncher
    protonup-qt
    qbittorrent
    satisfactory-mod-manager
    spotify
    vkBasalt
    vlc
  ];

  # Needed for Nerd Fonts to be found
  fonts.fontconfig.enable = true;

  # Microphone filters (noise gate)
  services.easyeffects.enable = true;
  services.syncthing.enable = true;

  programs.obs-studio.enable = true;
  programs.obs-studio.plugins = with pkgs.obs-studio-plugins; [
    obs-gstreamer
  ];

  programs.htop.enable = true;
  programs.htop.settings = {
    show_program_path = 0;
  };

  programs.mangohud.enable = true;
  programs.nix-index.enable = true;

  home.stateVersion = "22.05";
}
