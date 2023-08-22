{ pkgs, ... }: {
  # Plugins for EasyEffects
  home.packages = [ pkgs.lsp-plugins ];

  # Microphone filters (noise gate)
  services.easyeffects.enable = true;
}
