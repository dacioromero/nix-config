{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [./hardware-configuration.nix];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.registry.nixpkgs.flake = inputs.nixpkgs;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # Silence
  boot.initrd.verbose = false;
  boot.consoleLogLevel = 0;
  boot.kernelParams = [
    "quiet"
    "udev.log_level=3"
    "nvidia.NVreg_TemporaryFilePath=/var/tmp" # Nvidia recommends non-tmpfs
  ];

  # Experimenting with NixOS on SBCs
  boot.binfmt.emulatedSystems = ["armv7l-linux"];

  # Add more BTRFS mount options
  fileSystems."/".options = ["noatime" "compress=zstd"];
  fileSystems."/nix".options = ["noatime" "compress=zstd"];
  fileSystems."/home".options = ["noatime" "compress=zstd"];

  networking.hostName = "firetower";
  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "dnsmasq"; # DNS caching

  time.timeZone = "America/Los_Angeles";

  # Enable Nvidia drivers.
  services.xserver.videoDrivers = ["nvidia"];
  hardware.opengl.enable = true;
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.powerManagement.enable = true;

  # Enable X11, but get rid of xterm
  services.xserver.enable = true;
  services.xserver.excludePackages = [pkgs.xterm];
  services.xserver.desktopManager.xterm.enable = false;

  # Enable GNOME
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  environment.gnome.excludePackages =
    (with pkgs; [
      gnome-connections
      gnome-tour
    ])
    ++ (with pkgs.gnome; [
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

  # Gaming
  programs.gamemode.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # Some packages aren't on nixpkgs
  services.flatpak.enable = true;
  # Smart card support (YubiKey)
  services.pcscd.enable = true;

  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;
  environment.systemPackages = with pkgs; [virt-manager];

  system.stateVersion = "22.05";
}
