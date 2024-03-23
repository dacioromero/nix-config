{ pkgs, ... }: {
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # Enable X11, but get rid of xterm
  services.xserver.enable = true;
  services.xserver.excludePackages = [ pkgs.xterm ];
  services.xserver.desktopManager.xterm.enable = false;

  # Enable CUPS for printers
  services.printing.enable = true;
  # Enable SANE for scanners
  hardware.sane.enable = true;
  # Enable Avahi for printer discovery
  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;
  services.avahi.nssmdns6 = true;
  programs.system-config-printer.enable = true;

  environment.systemPackages = [ pkgs.firefox ];

  # Some packages aren't on nixpkgs
  services.flatpak.enable = true;
  # https://github.com/NixOS/nixpkgs/issues/119433
  fonts.fontDir.enable = true;
  # Smart card support (YubiKey)
  services.pcscd.enable = true;
}
