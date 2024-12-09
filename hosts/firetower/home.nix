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
    bambu-studio
    duf
    gimp
    google-chrome
    heroic
    inkscape
    jellyfin-mpv-shim
    krita
    mpv
    ncdu
    nerd-fonts.jetbrains-mono
    newsflash
    nil
    nmap
    prismlauncher
    protontricks
    qbittorrent
    r2modman
    spotify
    telegram-desktop
    vesktop
    vkBasalt
    wl-clipboard
  ];

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
