{ pkgs, config, ... }:
let
  # Assuming extensionUuid is unique to Gnome extensions
  extensions = builtins.filter (p: p ? "extensionUuid") config.home.packages;
in
{
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

  dconf.settings = {
    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/adwaita-l.webp";
      picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/adwaita-d.webp";
      primary-color = "#3071AE";
      secondary-color = "#000000";
    };

    "org/gnome/desktop/interface" = {
      clock-format = "12h";
      clock-show-date = true;
      color-scheme = "prefer-dark";
      enable-hot-corners = false;
      gtk-theme = "Adwaita-dark";
    };

    "org/gnome/desktop/screensaver" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/adwaita-l.webp";
      primary-color = "#3071AE";
      secondary-color = "#000000";
    };

    "org/gnome/desktop/wm/preferences".num-workspaces = 1;

    "org/gnome/mutter" = {
      dynamic-workspaces = false;
      edge-tiling = false;
      overlay-key = "Super_L";
      workspaces-only-on-primary = true;
    };

    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "list-view";
      search-view = "list-view";
    };

    # Enable installed extensions by default
    "org/gnome/shell".enabled-extensions = map (e: e.extensionUuid) extensions;
  };
}
