{ pkgs
, inputs
, ...
}:
let
  inherit (inputs) self nixos-hardware home-manager;
in
{
  imports =
    [
      ./hardware-configuration.nix
      home-manager.nixosModules.home-manager
    ]
    ++ (with nixos-hardware.nixosModules; [
      common-cpu-amd-pstate
      common-pc-ssd
    ])
    ++ (with self.nixosModules; [
      nix
      nixpkgs
      pc
      mullvad-vpn
      virt-manager
      hm
      kde
    ]);

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.supportedFilesystems = [ "ntfs" ];

  # Silence
  boot.initrd.verbose = false;
  boot.consoleLogLevel = 0;
  boot.kernelParams = [
    "quiet"
    "udev.log_level=3"
  ];

  boot.binfmt.emulatedSystems = [ "armv7l-linux" ];

  # Add more BTRFS mount options
  fileSystems."/".options = [ "noatime" "compress=zstd" ];
  fileSystems."/nix".options = [ "noatime" "compress=zstd" ];
  fileSystems."/home".options = [ "noatime" "compress=zstd" ];
  fileSystems."/boot".options = [ "noatime" ];

  networking.hostName = "firetower";
  networking.firewall.interfaces.wg-mullvad.allowedTCPPorts = [ 58651 54846 ];
  networking.firewall.interfaces.enp5s0.allowedTCPPorts = [ 25565 ];

  time.timeZone = "America/Los_Angeles";

  # Configure GPU
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;
  # hardware.opengl.extraPackages = [ pkgs.amdvlk ];
  # hardware.opengl.extraPackages32 = [ pkgs.driversi686Linux.amdvlk ];
  # boot.initrd.kernelModules = [ "amdgpu" ];
  # services.xserver.videoDrivers = [ "amdgpu" ];
  # services.xserver.videoDrivers = [ "amdgpu-pro" ];
  # programs.corectrl.enable = true;
  # programs.corectrl.gpuOverclock.enable = true;

  # Configure KDE
  # GTK Portal needed for libadwaita to read color preferences
  # https://www.reddit.com/r/ManjaroLinux/comments/w75e67/comment/ihitp14/?context=3
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  # Needed for KDE to write to Gnome settings for GTK/libadwaita apps
  programs.dconf.enable = true;
  # Disable all but main monitor
  # https://blog.victormendonca.com/2018/06/29/how-to-fix-sddm-on-multiple-screens/
  services.xserver.displayManager.setupCommands = ''
    ${pkgs.xorg.xrandr}/bin/xrandr \
      --output DisplayPort-0 --mode 2560x1440 --rate 165.08 \
      --output DisplayPort-1 --off \
      --output DisplayPort-2 --off
  '';
  services.xserver.displayManager.defaultSession = "plasmawayland";
  services.xserver.desktopManager.plasma5.excludePackages = [ pkgs.libsForQt5.konsole ];

  # Gaming
  programs.gamemode.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  services.printing.drivers = [ pkgs.hplipWithPlugin ];
  services.hardware.openrgb.enable = true;
  services.ratbagd.enable = true;

  environment.systemPackages = [ pkgs.piper ];

  users.users.dacio = {
    isNormalUser = true;
    description = "Dacio";
    group = "dacio";
    uid = 1000;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  users.groups.dacio.gid = 1000;
  home-manager.users.dacio = import ./home.nix;

  system.stateVersion = "22.05";
}
