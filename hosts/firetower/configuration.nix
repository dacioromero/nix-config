{ pkgs
, inputs
, config
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
  boot.loader.timeout = 0;
  # Zen 3 power monitoring
  boot.kernelModules = [ "zenpower" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.zenpower ];
  boot.blacklistedKernelModules = [ "k10temp" ];

  # Add more BTRFS mount options
  fileSystems."/".options = [ "noatime" "compress=zstd" ];
  fileSystems."/nix".options = [ "noatime" "compress=zstd" ];
  fileSystems."/home".options = [ "noatime" "compress=zstd" ];
  fileSystems."/boot".options = [ "noatime" ];

  # Many distros enable this by default
  zramSwap.enable = true;
  # With 32 GiB of RAM and zram enabled OOM is unlikely
  systemd.oomd.enable = false;
  systemd.services.NetworkManager-wait-online.enable = false;

  networking.hostName = "firetower";
  networking.firewall.interfaces.wg-mullvad.allowedTCPPorts = [ 58651 ];
  networking.firewall.interfaces.enp5s0.allowedTCPPorts = [ 25565 ];

  time.timeZone = "America/Los_Angeles";

  # Configure GPU
  # Enable AMDVLK but force RADV as default. AMDVLK has better perfomance in some games (DOOM Eternal)
  hardware.amdgpu.amdvlk = true;
  environment.variables.AMD_VULKAN_ICD = "RADV";
  # Fix no video after kexec
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
  # Overclock
  # https://wiki.archlinux.org/title/AMDGPU#Overclocking
  # https://www.kernel.org/doc/html/v6.1/gpu/amdgpu/thermal.html
  powerManagement.powerUpCommands =
    let
      gpuDevice = "/sys/devices/pci0000:00/0000:00:03.1/0000:09:00.0/0000:0a:00.0/0000:0b:00.0";
    in
    ''
      echo '293000000' > ${gpuDevice}/hwmon/hwmon*/power1_cap # max power limit to 293 W
      echo 'manual'    > ${gpuDevice}/power_dpm_force_performance_level # needed for p-state and power profile
      echo 's 1 2650'  > ${gpuDevice}/pp_od_clk_voltage # overclock gpu core to 2650 MHz
      echo 'm 1 1050'  > ${gpuDevice}/pp_od_clk_voltage # overclock mem to 2100 Mhz
      echo 'vo -60'    > ${gpuDevice}/pp_od_clk_voltage # underclock by 60 mV
      echo 'c'         > ${gpuDevice}/pp_od_clk_voltage
      echo '3'         > ${gpuDevice}/pp_dpm_mclk # highest p-state
      echo '5'         > ${gpuDevice}/pp_power_profile_mode # compute power profile
    '';
  boot.kernelParams = [ "amdgpu.ppfeaturemask=0xffffffff" ];
  # Mismatched Mesa versions crash Plasma
  # https://github.com/NixOS/nixpkgs/issues/223729
  nixpkgs.overlays = [
    (final: prev: rec {
      libsForQt5 = prev.libsForQt5.overrideScope' (qtFinal: qtPrev:
        let
          plasma5 = qtPrev.plasma5.overrideScope' (plasmaFinal: plasmaPrev: {
            kpipewire = plasmaPrev.kpipewire.override { mesa = prev.mesa_23; };
            kwin = plasmaPrev.kwin.override { mesa = prev.mesa_23; };
            xdg-desktop-portal-kde = plasmaPrev.xdg-desktop-portal-kde.override { mesa = prev.mesa_23; };
          });
        in
        plasma5 // { inherit plasma5; });

      plasma5Packages = libsForQt5;
    })
  ];
  # Use latest Mesa
  hardware.opengl.mesaPackage = pkgs.mesa_23;
  hardware.opengl.mesaPackage32 = pkgs.pkgsi686Linux.mesa_23;

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
  environment.plasma5.excludePackages = [ pkgs.libsForQt5.konsole ];
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
