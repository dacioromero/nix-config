{ pkgs, ... }: {
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.desktopManager.plasma5.excludePackages = with pkgs.libsForQt5; [
    oxygen
    elisa
    khelpcenter
  ];
  environment.systemPackages = with pkgs; [
    ark
    kcalc
  ];
}
