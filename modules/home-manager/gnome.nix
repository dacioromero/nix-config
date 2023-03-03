{ pkgs, ... }: {
  home.packages = with pkgs.gnomeExtensions; [
    appindicator
    arcmenu
    blur-my-shell
    dash-to-panel
    hibernate-status-button
    inhibit-suspend
    no-overview
    quick-settings-tweaker
    syncthing-indicator
    tiling-assistant
  ];

  # NixOS doesn't set a default cursor can cause issues
  # https://github.com/alacritty/alacritty/issues/4780
  # https://github.com/NixOS/nixpkgs/issues/22652
  home.pointerCursor = {
    package = pkgs.gnome.adwaita-icon-theme;
    name = "Adwaita";
  };

  services.gpg-agent.pinentryFlavor = "gnome3";

  # gnome-keyring sets SSH_AUTH_SOCK which conflicts with gpg-agent
  # https://github.com/NixOS/nixpkgs/issues/101616
  xdg.configFile."autostart/gnome-keyring-ssh.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Hidden=true
  '';

  # Qt styling isn't controlled by Gnome or gnome-tweaks
  qt.enable = true;
  qt.platformTheme = "gnome";
  qt.style = {
    package = pkgs.adwaita-qt;
    name = "adwaita-dark";
  };
}
