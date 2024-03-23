{ pkgs
, inputs
, ...
}: {
  imports = builtins.attrValues {
    inherit (inputs.self.homeManagerModules)
      home
      wezterm
      linux
      kde
      easyeffects;
  };

  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    discord
    duf
    element-desktop
    google-chrome
    heroic
    krita
    lutris
    mission-center
    ncdu
    newsflash
    nil
    prismlauncher
    protontricks
    protonup-qt
    qbittorrent
    r2modman
    signal-desktop
    slack
    spotify
    telegram-desktop
    vkBasalt
    vlc
    wl-clipboard
  ];

  # https://www.reddit.com/r/archlinux/comments/190dvl8/pipewirewayland_how_to_stop_applications_from/
  xdg.configFile."wireplumber/main.lua.d/99-stop-microphone-auto-adjust.lua".text = ''
    rule = {
      matches = {
        {
          { "application.process.binary", "=", "chrome" },
          { "application.process.binary", "=", "electron" },
        },
      },
      default_permissions = "rx",
    }
    table.insert(default_access.rules, rule)
  '';

  # Needed for Nerd Fonts to be found
  fonts.fontconfig.enable = true;

  services.syncthing.enable = true;

  programs.obs-studio.enable = true;
  programs.obs-studio.plugins = with pkgs.obs-studio-plugins; [
    obs-vaapi
    obs-vkcapture
  ];

  programs.mangohud.enable = true;
  programs.mangohud.settings = {
    fps_limit = [ 0 60 30 ];
    toggle_fps_limit = "F1";
    gpu_temp = true;
    gpu_core_clock = true;
    gpu_mem_clock = true;
    gpu_power = true;
    cpu_temp = true;
    cpu_power = true;
    cpu_mhz = true;
    vram = true;
    ram = true;
    fps = true;
    vulkan_driver = true;
    wine = true;
    frame_timing = true;
    position = "middle-right";
  };
  programs.nix-index.enable = true;

  home.stateVersion = "22.05";
}
