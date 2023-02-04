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
    webcord
    element-desktop
    goverlay
    insomnia
    lsp-plugins # Plugins for EasyEffects
    mangohud
    prismlauncher
    qbittorrent
    spotify
    tdesktop
  ];

  # Needed for Nerd Fonts to be found
  fonts.fontconfig.enable = true;

  # Microphone filters (noise gate)
  services.syncthing.enable = true;
  services.easyeffects.enable = true;

  programs.lf = {
    enable = true;
    keybindings."<delete>" = "delete";
  };

  home.stateVersion = "22.05";
}
