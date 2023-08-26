{ pkgs
, inputs
, ...
}:
let
  inherit (inputs)
    self
    nixos-hardware
    lanzaboote
    home-manager
    ;
in
{
  imports =
    [
      ./hardware-configuration.nix
      nixos-hardware.nixosModules.lenovo-thinkpad-x1-6th-gen
      lanzaboote.nixosModules.lanzaboote
      home-manager.nixosModules.home-manager
    ]
    ++ (with self.nixosModules; [
      nix
      nixpkgs
      pc
      gnome
      mullvad-vpn
      virt-manager
      hm
      zram
      syncthing-firewall
    ]);

  # Secure boot signing and bootloader
  boot.loader.efi.canTouchEfiVariables = true; # Likely does nothing with Lanzaboote
  boot.bootspec.enable = true;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };
  boot.loader.timeout = 0;

  # Resume from swap device
  boot.resumeDevice = "/dev/disk/by-uuid/361b647d-e76b-4fb9-b13b-9f2e0b9af179";

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.supportedFilesystems = [ "exfat" ];

  # More graceful booting
  boot.plymouth.enable = true;
  boot.initrd.systemd.enable = true;

  # Silence
  boot.initrd.verbose = false;
  boot.consoleLogLevel = 3;

  boot.kernelParams = [
    # More silence
    "quiet"
    "rd.udev.log_level=3"
    # using zram w/ physical swap, should disable zswap
    "zswap.enabled=0"
  ];

  # More filesystem mount options
  fileSystems."/".options = [ "noatime" "compress=zstd" ];
  fileSystems."/nix".options = [ "noatime" "compress=zstd" ];
  fileSystems."/home".options = [ "noatime" "compress=zstd" ];
  fileSystems."/boot".options = [ "noatime" ];

  networking.hostName = "firepad";
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  networking.networkmanager.dns = "dnsmasq"; # DNS caching

  time.timeZone = "America/Los_Angeles";

  # Battery care
  # Attempting to limit battery percentage between 20 and 80
  powerManagement.powerUpCommands = ''
    if [ -d "/sys/class/power_supply/BAT0" ]; then
      echo 80 > /sys/class/power_supply/BAT0/charge_control_end_threshold
      echo 75 > /sys/class/power_supply/BAT0/charge_control_start_threshold
    fi
  '';
  services.upower.percentageLow = 25;
  services.upower.percentageCritical = 22;
  services.upower.percentageAction = 20;

  # Battery efficiency
  # auto-cpufreq switches modes intelligently, disable others
  services.power-profiles-daemon.enable = false; # Auto-enabled by Gnome
  services.tlp.enable = false; # Auto-enabled by nixos-hardware when PPD is disabled
  services.auto-cpufreq.enable = true;

  # Firmware updates supported
  services.fwupd.enable = true;

  # Home printer drivers
  services.printing.drivers = [ pkgs.hplipWithPlugin ];

  # Private VPN
  services.tailscale.enable = true;

  # Home media server
  # TODO: Move to dedicated machine
  services.jellyfin.enable = true;
  services.jellyfin.openFirewall = true;

  programs.adb.enable = true;

  programs.gamemode.enable = true;

  users.users.dacio = {
    isNormalUser = true;
    description = "Dacio";
    group = "dacio";
    uid = 1000;
    extraGroups = [ "wheel" "adbusers" "networkmanager" ];
  };
  # Emulate `useradd --user-group`
  users.groups.dacio.gid = 1000;
  home-manager.users.dacio = import ./home.nix;

  system.stateVersion = "22.11";
}
