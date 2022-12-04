{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../modules/home-manager/home.nix
  ];

  home.username = "dacio";
  home.homeDirectory = "/home/dacio";

  home.sessionVariables = {
    NIXOS_OZONE_WL = 1;
  };

  home.packages = with pkgs;
    [
      spotify
      google-chrome
      firefox-devedition-bin
      discord
      goverlay
      mangohud
      qbittorrent
      (nerdfonts.override {fonts = ["JetBrainsMono"];})
      gnome-extension-manager
      adw-gtk3
    ]
    ++ (with pkgs.gnomeExtensions; [
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

  qt.enable = true;
  qt.platformTheme = "gnome";
  qt.style = {
    package = pkgs.adwaita-qt;
    name = "adwaita-dark";
  };
}
