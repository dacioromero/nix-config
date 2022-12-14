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

  home.packages = with pkgs; [
    (nerdfonts.override {fonts = ["JetBrainsMono"];})
    cryptomator
    discord
    element-desktop
    insomnia
    qbittorrent
    spotify
    tdesktop
  ];

  fonts.fontconfig.enable = true;

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    defaultCacheTtl = 60;
    maxCacheTtl = 120;
    pinentryFlavor = "gnome3";
  };

  services.syncthing.enable = true;

  home.stateVersion = "22.11";
}
