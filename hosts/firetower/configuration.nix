{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = with inputs.nixos-hardware.nixosModules; [
    common-cpu-amd-pstate
    common-gpu-nvidia-nonprime
    ./hardware-configuration.nix
  ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = builtins.attrValues inputs.self.overlays;
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

  networking.firewall.interfaces.wg-mullvad.allowedTCPPorts = [58651];

  time.timeZone = "America/Los_Angeles";

  # Configure Nvidia
  hardware.opengl.driSupport32Bit = true;
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.powerManagement.enable = true;

  # Gnome doesn't suspend prior to 525.60.11
  # TODO: Remove after 525.60.11
  # https://forums.developer.nvidia.com/t/trouble-suspending-with-510-39-01-linux-5-16-0-freezing-of-tasks-failed-after-20-009-seconds/200933/12
  # https://gitlab.gnome.org/GNOME/gnome-shell/-/issues/5772
  # https://www.nvidia.com/Download/driverResults.aspx/196723/en-us/
  systemd.services.gnome-suspend = {
    enable = true;
    description = "Suspend gnome-shell";
    before = [
      "systemd-suspend.service"
      "systemd-hibernate.service"
      "nvidia-suspend.service"
      "nvidia-hibernate.service"
    ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.busybox}/bin/killall -STOP gnome-shell";
    };
    wantedBy = ["systemd-suspend.service" "systemd-hibernate.service"];
  };

  systemd.services.gnome-resume = {
    enable = true;
    description = "Resume gnome-shell";
    before = [
      "systemd-suspend.service"
      "systemd-hibernate.service"
      "nvidia-resume.service"
    ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.busybox}/bin/killall -CONT gnome-shell";
    };
    wantedBy = ["systemd-suspend.service" "systemd-hibernate.service"];
  };

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
  services.hardware.openrgb.enable = true;
  services.ratbagd.enable = true;
  services.mullvad-vpn.enable = true;

  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;
  environment.systemPackages = with pkgs; [virt-manager gnome.gnome-tweaks piper mullvad-vpn];

  system.stateVersion = "22.05";
}
