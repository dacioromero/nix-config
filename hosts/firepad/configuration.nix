{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = with inputs.nixos-hardware.nixosModules; [
    ./hardware-configuration.nix
    lenovo-thinkpad-x1-6th-gen
  ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = builtins.attrValues inputs.self.overlays;
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.registry.nixpkgs.flake = inputs.nixpkgs;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.supportedFilesystems = ["ntfs"];

  networking.hostName = "firepad";
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  networking.networkmanager.dns = "dnsmasq"; # DNS caching

  time.timeZone = "America/Los_Angeles";

  # Enable X11, but get rid of xterm
  services.xserver.enable = true;
  services.xserver.excludePackages = [pkgs.xterm];
  services.xserver.desktopManager.xterm.enable = false;

  # Enable GNOME
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.gnome.gnome-browser-connector.enable = true;
  environment.gnome.excludePackages = with pkgs;
    [
      gnome-connections
      gnome-tour
    ]
    ++ (with gnome; [
      baobab # disk usage
      epiphany # browser
      geary # email client
      gnome-calendar
      gnome-characters
      gnome-clocks
      gnome-contacts
      gnome-logs
      gnome-maps
      gnome-music
      gnome-software
      gnome-weather
      yelp # help
    ]);

  # Enable CUPS for printers
  services.printing.enable = true;
  # Enable Avahi for printer discovery
  services.avahi.enable = true;
  services.avahi.nssmdns = true;

  # Enable sound with Pipewire
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    #jack.enable = true;
  };

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # Some packages aren't on nixpkgs
  services.flatpak.enable = true;
  # Smart card support (YubiKey)
  services.pcscd.enable = true;
  services.mullvad-vpn.enable = true;

  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;
  environment.systemPackages = with pkgs; [virt-manager gnome.gnome-tweaks mullvad-vpn firefox];

  system.stateVersion = "22.11";
}
