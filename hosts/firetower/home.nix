{
  pkgs,
  inputs,
  ...
}: {
  imports = with inputs.self.homeManagerModules; [
    home
    alacritty
    gnome
  ];

  # Force Wayland on apps like VSCode and Firefox
  home.sessionVariables."NIXOS_OZONE_WL" = 1;
  # Make hardware decode work on Nvidia
  # https://github.com/elFarto/nvidia-vaapi-driver#firefox
  home.sessionVariables."MOZ_DISABLE_RDD_SANDBOX" = 1;

  home.packages = with pkgs; [
    (nerdfonts.override {fonts = ["JetBrainsMono"];})
    adw-gtk3
    element-desktop
    gnome-feeds
    goverlay
    insomnia
    lsp-plugins # Plugins for EasyEffects
    prismlauncher
    protonup-qt
    psst
    qbittorrent
    satisfactory-mod-manager
    tdesktop
    vkBasalt
    webcord
  ];

  # Needed for Nerd Fonts to be found
  fonts.fontconfig.enable = true;

  # Microphone filters (noise gate)
  services.easyeffects.enable = true;
  services.syncthing.enable = true;

  programs.lf = {
    enable = true;
    keybindings."<delete>" = "delete";
  };

  programs.mangohud.enable = true;

  home.stateVersion = "22.05";
}
