{ pkgs, ... }: {
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  networking.networkmanager.dns = "dnsmasq"; # DNS caching

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
  services.avahi.nssmdns = true;
  programs.system-config-printer.enable = true;

  # Enable sound with Pipewire
  security.rtkit.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  environment.systemPackages = [ pkgs.firefox ];

  # Some packages aren't on nixpkgs
  services.flatpak.enable = true;
  # https://github.com/NixOS/nixpkgs/issues/119433
  fonts.fontDir.enable = true;
  # Smart card support (YubiKey)
  services.pcscd.enable = true;
}
