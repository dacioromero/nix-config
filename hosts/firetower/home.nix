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

  home.packages = with pkgs; [
    spotify
    google-chrome
    firefox-devedition-bin
    discord
    (nerdfonts.override {fonts = ["JetBrainsMono"];})
    gnome-extension-manager
    gnomeExtensions.appindicator
    gnomeExtensions.arcmenu
    gnomeExtensions.blur-my-shell
    gnomeExtensions.dash-to-panel
    gnomeExtensions.gamemode
    gnomeExtensions.no-overview
    gnomeExtensions.quick-settings-tweaker
    gnomeExtensions.tiling-assistant
  ];

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

  # # Needed for proper cursor on non-NixOS
  # home.pointerCursor = {
  #   package = pkgs.gnome.adwaita-icon-theme;
  #   name = "Adwaita";
  # };

  # # If we are the first ones to initialize XDG_DATA_DIRS, we need to populate more
  # xdg.systemDirs.data = ["$HOME/.nix-profile/share" "/usr/local/share" "/usr/share"];

  # # Seems to fix gpg on non-NixOS
  # programs.gpg.scdaemonSettings.disable-ccid = true;
}
