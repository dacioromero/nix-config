{
  config,
  pkgs,
  self,
  ...
}: {
  imports = with self.homeManagerModules; [home alacritty];

  nixpkgs.config.firefox.enableGnomeExtensions = true;

  home.username = "dacio";
  home.homeDirectory = "/home/dacio";

  # Force Wayland on apps like VSCode and Firefox
  home.sessionVariables."NIXOS_OZONE_WL" = 1;
  # Make hardware decode work on Nvidia
  # https://github.com/elFarto/nvidia-vaapi-driver#firefox
  home.sessionVariables."MOZ_DISABLE_RDD_SANDBOX" = 1;

  home.packages = with pkgs;
    [
      spotify
      # firefox-devedition-bin doesn't support gnome extensions and its icon is wrong
      # https://github.com/NixOS/nixpkgs/issues/127968
      firefox
      discord-gpu
      goverlay
      mangohud
      qbittorrent
      (nerdfonts.override {fonts = ["JetBrainsMono"];})
      adw-gtk3
      insomnia
      prismlauncher
      lsp-plugins # Plugins for EasyEffects
      transmission-gtk
      tdesktop
      element-desktop
    ]
    ++ (with gnomeExtensions; [
      appindicator
      arcmenu
      blur-my-shell
      dash-to-panel
      gamemode
      no-overview
      quick-settings-tweaker
      tiling-assistant
    ]);

  fonts.fontconfig.enable = true;

  # NixOS doesn't set a default cursor can cause issues
  # https://github.com/alacritty/alacritty/issues/4780
  # https://github.com/NixOS/nixpkgs/issues/22652
  home.pointerCursor = {
    package = pkgs.gnome.adwaita-icon-theme;
    name = "Adwaita";
  };

  # gnome-keyring sets SSH_AUTH_SOCK which conflicts with gpg-agent
  # https://github.com/NixOS/nixpkgs/issues/101616
  xdg.configFile."autostart/gnome-keyring-ssh.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Hidden=true
  '';

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    defaultCacheTtl = 60;
    maxCacheTtl = 120;
    pinentryFlavor = "gnome3";
  };

  services.syncthing.enable = true;
  services.easyeffects.enable = true;

  # Qt styling isn't controlled by Gnome or gnome-tweaks
  qt.enable = true;
  qt.platformTheme = "gnome";
  qt.style = {
    package = pkgs.adwaita-qt;
    name = "adwaita-dark";
  };

  home.stateVersion = "22.05";
}
