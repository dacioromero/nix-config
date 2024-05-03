{ pkgs, ... }: {
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    elisa
    khelpcenter
  ];
  environment.systemPackages = with pkgs.kdePackages; [
    ark
    kcalc
    skanlite
  ];
  # GTK Portal needed for libadwaita to read color preferences
  # https://www.reddit.com/r/ManjaroLinux/comments/w75e67/comment/ihitp14/?context=3
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  # Needed for KDE to write to Gnome settings for GTK/libadwaita apps
  programs.dconf.enable = true;
}
