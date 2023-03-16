{ pkgs
, inputs
, ...
}: {
  imports = with inputs.self.homeManagerModules; [
    home
    alacritty
    gnome
    linux
  ];

  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    cryptomator
    discord
    qbittorrent
    spotify
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

  dconf.settings = {
    "org/gnome/desktop/interface".show-battery-percentage = true;
    "org/gnome/desktop/sound".allow-volume-above-100-percent = true;
    # https://wiki.archlinux.org/title/HiDPI#Wayland
    "org/gnome/mutter".experimental-features = [ "scale-monitor-framebuffer" ];
  };

  home.stateVersion = "22.11";
}
