{ pkgs
, inputs
, lib
, ...
}: {
  imports = with inputs.self.homeManagerModules; [
    home
    wezterm
    linux
    easyeffects
    kde
  ];

  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    discord
    qbittorrent
    spotify
    telegram-desktop
  ];

  fonts.fontconfig.enable = true;

  services.syncthing.enable = true;

  programs.nix-index.enable = true;

  programs.starship.settings = {
    git_metrics.disabled = lib.mkForce true;
    git_status.disabled = lib.mkForce true;
  };

  # dconf.settings = {
  #   "org/gnome/desktop/interface".show-battery-percentage = true;
  #   "org/gnome/desktop/sound".allow-volume-above-100-percent = true;
  #   # https://wiki.archlinux.org/title/HiDPI#Wayland
  #   "org/gnome/mutter".experimental-features = [ "scale-monitor-framebuffer" ];
  # };

  home.stateVersion = "22.11";
}
