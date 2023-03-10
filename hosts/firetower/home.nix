{ pkgs
, inputs
, config
, ...
}: {
  imports = with inputs.self.homeManagerModules; [
    home
    wezterm
    linux
  ];

  # Force Wayland on apps like VSCode and Firefox
  home.sessionVariables."NIXOS_OZONE_WL" = 1;

  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    discord
    element-desktop
    gnome-feeds
    goverlay
    lsp-plugins # Plugins for EasyEffects
    prismlauncher
    protonup-qt
    psst
    qbittorrent
    satisfactory-mod-manager
    vkBasalt
  ];

  # Needed for Nerd Fonts to be found
  fonts.fontconfig.enable = true;

  services.gpg-agent.pinentryFlavor = "qt";

  # Activate session variables in KDE Plasma
  # https://github.com/nix-community/home-manager/issues/1011
  xdg.configFile."plasma-workspace/env/hm-session-vars.sh".text = ''
    . "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"
  '';

  # Microphone filters (noise gate)
  services.easyeffects.enable = true;
  services.syncthing.enable = true;

  programs.lf = {
    enable = true;
    keybindings."<delete>" = "delete";
  };

  programs.mangohud.enable = true;
  # programs.mangohud.enableSessionWide = true;

  home.stateVersion = "22.05";
}
