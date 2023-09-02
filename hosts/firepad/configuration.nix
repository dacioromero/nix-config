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
      mullvad-vpn
      virt-manager
      hm
      zram
      syncthing-firewall
      kde
      pipewire
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

  boot.kernelPackages = pkgs.linuxPackages_zen;

  boot.supportedFilesystems = [ "exfat" "ntfs" ];

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
    # Required for VT-d
    "intel_iommu=on"
  ];

  # More filesystem mount options
  fileSystems."/".options = [ "noatime" "compress=zstd" ];
  fileSystems."/nix".options = [ "noatime" "compress=zstd" ];
  fileSystems."/home".options = [ "noatime" "compress=zstd" ];
  fileSystems."/boot".options = [ "noatime" ];

  networking.hostName = "firepad";
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  networking.networkmanager.dns = "dnsmasq"; # DNS caching
  systemd.services.NetworkManager-wait-online.enable = false;

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
  # Let nixos-hardware enable tlp, avoiding performance cpu governor
  services.power-profiles-daemon.enable = false; # Auto-enabled by Gnome
  # services.tlp.enable = false; # Auto-enabled by nixos-hardware when PPD is disabled
  # services.auto-cpufreq.enable = true; # auto-cpufreq switches modes intelligently

  # SDAC can stop outputting audio after being suspend, stop suspend.
  # https://davejansen.com/disable-wireplumber-pipewire-suspend-on-idle-pops-delays-noise/
  # https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/1369
  # https://discourse.nixos.org/t/prevent-pipewire-from-putting-audio-to-sleep/28505/2
  environment.etc."wireplumber/main.lua.d/90-sdac-no-suspend.lua".text = ''
    rule = {
      matches = {
        {
          { "node.name", "matches", "alsa_output.usb-Grace_Design_SDAC-*" },
        },
      },
      apply_properties = {
        ["session.suspend-timeout-seconds"] = 0,
      },
    }

    table.insert(alsa_monitor.rules, rule)
  '';

  environment.etc."wireplumber/main.lua.d/90-disable-unused.lua".text = ''
    rule = {
      matches = {
        {
          { "device.name", "equals", "alsa_card.usb-Lenovo_ThinkPad_Thunderbolt_3_Dock_USB_Audio_000000000000-00" },
        },
      },
      apply_properties = {
        ["device.disabled"] = true,
      },
    }

    table.insert(alsa_monitor.rules, rule)
  '';

  # Firmware updates supported
  services.fwupd.enable = true;
  # ThinkPad Thunderbolt 3 Dock Gen 2 firmware only available in testing
  # https://github.com/fwupd/firmware-lenovo/issues/5
  services.fwupd.extraRemotes = [ "lvfs-testing" ];

  # Home printer drivers
  services.printing.drivers = [ pkgs.hplipWithPlugin ];

  # Private VPN
  services.tailscale.enable = true;

  # Thunderbolt daemon
  services.hardware.bolt.enable = true;

  services.ratbagd.enable = true;
  environment.systemPackages = with pkgs; [
    piper
    plasma5Packages.plasma-thunderbolt
  ];

  virtualisation.spiceUSBRedirection.enable = true;

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
    extraGroups = [
      "wheel"
      "adbusers"
      "networkmanager"
      "libvirtd"
    ];
  };
  # Emulate `useradd --user-group`
  users.groups.dacio.gid = 1000;
  home-manager.users.dacio = import ./home.nix;

  system.stateVersion = "22.11";
}
