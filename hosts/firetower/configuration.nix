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
      common-gpu-amd
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
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.supportedFilesystems = [ "ntfs" ];
  boot.binfmt.emulatedSystems = [ "armv7l-linux" ];

  # Add more BTRFS mount options
  fileSystems."/".options = [ "noatime" "compress=zstd" ];
  fileSystems."/nix".options = [ "noatime" "compress=zstd" ];
  fileSystems."/home".options = [ "noatime" "compress=zstd" ];
  fileSystems."/boot".options = [ "noatime" ];

  # Most OS's enable this by default
  zramSwap.enable = true;
  # With 32 GiB of RAM and zram enabled OOM is unlikely
  systemd.oomd.enable = false;

  networking.hostName = "firetower";
  networking.firewall.interfaces.wg-mullvad.allowedTCPPorts = [ 58651 ];
  networking.firewall.interfaces.enp5s0.allowedTCPPorts = [ 25565 ];

  time.timeZone = "America/Los_Angeles";

  # Configure GPU
  # hardware.amdgpu.amdvlk = true;
  # programs.corectrl.enable = true;
  # programs.corectrl.gpuOverclock.enable = true;
  # Adapted from https://wiki.archlinux.org/title/kexec#No_kernel_mode-setting_(Nvidia)
  systemd.services.unmodeset = {
    description = "Unload amdgpu modules from kernel";
    documentation = [ "man:modprobe(8)" ];
    unitConfig.DefaultDependencies = "no";
    after = [ "umount.target" ];
    before = [ "kexec.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.kmod}/bin/modprobe -r amdgpu";
    };
    wantedBy = [ "kexec.target" ];
  };

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
      --output DP-1 --mode 2560x1440 --rate 165.08 \
      --output DP-2 --off \
      --output DP-3 --off
  '';
  services.xserver.displayManager.defaultSession = "plasmawayland";
  services.xserver.desktopManager.plasma5.excludePackages = [ pkgs.libsForQt5.konsole ];
  # https://wiki.archlinux.org/title/SDDM#KDE_Plasma_Wayland_hangs_on_shutdown_and_reboot
  systemd.services.display-manager.serviceConfig.TimeoutStopSec = 5;

  # Gaming
  programs.gamemode.enable = true;
  programs.steam.enable = true;

  services.printing.drivers = [ pkgs.hplipWithPlugin ];

  services.ratbagd.enable = true;
  environment.systemPackages = [ pkgs.piper ];

  users.users.dacio = {
    isNormalUser = true;
    description = "Dacio";
    group = "dacio";
    uid = 1000;
    extraGroups = [ "wheel" "networkmanager" ];
  };
  # Emulate `useradd --user-group`
  users.groups.dacio.gid = 1000;
  home-manager.users.dacio = import ./home.nix;

  system.stateVersion = "22.05";
}
