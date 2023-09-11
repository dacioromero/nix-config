{ pkgs, ... }: {
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  environment.plasma5.excludePackages = with pkgs.libsForQt5; [
    oxygen
    elisa
    khelpcenter
  ];
  environment.systemPackages = with pkgs; [
    ark
    kcalc
    skanlite
  ];
  # GTK Portal needed for libadwaita to read color preferences
  # https://www.reddit.com/r/ManjaroLinux/comments/w75e67/comment/ihitp14/?context=3
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  # Needed for KDE to write to Gnome settings for GTK/libadwaita apps
  programs.dconf.enable = true;
  services.xserver.displayManager.defaultSession = "plasmawayland";
}
