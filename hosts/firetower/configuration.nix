{ pkgs
, inputs
, config
, lib
, ...
}:
let
  inherit (inputs)
    self
    nixos-hardware
    home-manager
    lanzaboote
    ;
in
{
  imports =
    (lib.singleton ./hardware-configuration.nix)
    ++ (lib.attrValues {
      inherit (lanzaboote.nixosModules) lanzaboote;
      inherit (home-manager.nixosModules) home-manager;
      inherit (nixos-hardware.nixosModules)
        common-cpu-amd-pstate
        common-pc-ssd
        common-gpu-amd
        ;
      inherit (self.nixosModules)
        nix
        nixpkgs
        pc
        virt-manager
        hm
        kde
        zram
        syncthing-firewall
        pipewire
        xwaylandvideobridge
        ;
    });

  nix.settings.cores = 4;
  nix.settings.max-jobs = 4;

  # Bootloader
  boot.loader.efi.canTouchEfiVariables = true; # Likely does nothing with Lanzaboote
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };
  boot.loader.timeout = 0;
  boot.initrd.systemd.enable = true; # Automatic decrypt with TPM

  # Zen 3 power monitoring
  boot.kernelModules = [ "zenpower" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.zenpower ];
  boot.blacklistedKernelModules = [ "k10temp" ];

  boot.supportedFilesystems = [ "ntfs" ];

  # More filesystem mount options
  fileSystems."/".options = [ "noatime" "compress=zstd" ];
  fileSystems."/nix".options = [ "noatime" "compress=zstd" ];
  fileSystems."/home".options = [ "noatime" "compress=zstd" ];
  fileSystems."/boot".options = [ "noatime" ];

  # dbus-broker is more performant
  # https://archlinux.org/news/making-dbus-broker-our-default-d-bus-daemon/
  services.dbus.implementation = "broker";

  # systemd.services.NetworkManager-wait-online.enable = false;
  systemd.network.wait-online.enable = false;

  networking.hostName = "firetower";

  networking.useDHCP = false;
  # Bridging so VMs can get IPs on LAN subnet
  networking.interfaces.br0.useDHCP = true;
  networking.bridges.br0.interfaces = [ "enp6s0" ];
  # https://github.com/NixOS/nixpkgs/pull/264967
  networking.useNetworkd = true;

  time.timeZone = "America/Los_Angeles";

  # Configure GPU
  # Early KMS isn't helpful
  hardware.amdgpu.loadInInitrd = false;
  # Overclock
  # https://wiki.archlinux.org/title/AMDGPU#Overclocking
  # https://www.kernel.org/doc/html/v6.1/gpu/amdgpu/thermal.html
  # https://github.com/sibradzic/amdgpu-clocks/blob/master/amdgpu-clocks.service
  systemd.services.amdgpu-overclock = {
    description = "Overclock AMD GPU";
    after = [ "suspend.target" "multi-user.target" "systemd-user-sessions.service" ];
    wantedBy = [ "sleep.target" "multi-user.target" ];
    wants = [ "modprobe@amdgpu.service" ];
    script =
      let
        gpuDevice = "/sys/devices/pci0000:00/0000:00:03.1/0000:0a:00.0/0000:0b:00.0/0000:0c:00.0";
      in
      ''
        echo '293000000' > ${gpuDevice}/hwmon/hwmon6/power1_cap # max power limit to 293 W
        echo 'manual'    > ${gpuDevice}/power_dpm_force_performance_level # needed for p-state and power profile
        echo 's 1 2650'  > ${gpuDevice}/pp_od_clk_voltage # overclock gpu core to 2650 MHz
        echo 'm 1 1050'  > ${gpuDevice}/pp_od_clk_voltage # overclock mem to 2100 Mhz
        echo 'vo -60'    > ${gpuDevice}/pp_od_clk_voltage # underclock by 60 mV
        echo 'c'         > ${gpuDevice}/pp_od_clk_voltage
        echo '3'         > ${gpuDevice}/pp_dpm_mclk # highest p-state
        echo '1'         > ${gpuDevice}/pp_power_profile_mode # 3d full screen power profile
      '';
    serviceConfig.Type = "oneshot";
  };
  # https://wiki.archlinux.org/title/AMDGPU#Boot_parameter
  boot.kernelParams = [ "amdgpu.ppfeaturemask=0xfff7ffff" ];

  # Configure KDE
  # Disable all but main monitor
  # https://blog.victormendonca.com/2018/06/29/how-to-fix-sddm-on-multiple-screens/
  services.xserver.displayManager.setupCommands = ''
    ${pkgs.xorg.xrandr}/bin/xrandr \
      --output DP-1 --mode 2560x1440 --rate 165.08 \
      --output HDMI-1 --off \
      --output DP-3 --off
  '';
  environment.plasma5.excludePackages = [ pkgs.libsForQt5.konsole ];

  # Gaming
  programs.gamemode.enable = true;
  programs.gamescope.enable = true;
  programs.steam.enable = true;
  programs.steam.remotePlay.openFirewall = true;
  programs.steam.localNetworkGameTransfers.openFirewall = true;

  # Home printer drivers
  services.printing.drivers = [ pkgs.hplipWithPlugin ];

  # Mouse settings
  services.ratbagd.enable = true;
  environment.systemPackages = [ pkgs.piper ];

  # Wacom Intuos
  # TODO: Consider wacom kernel driver and pkgs.wacomtablet
  hardware.opentabletdriver.enable = true;

  # Private VPN
  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "client";
  services.tailscale.openFirewall = true;

  # Enable secure boot and TPM for VMs
  virtualisation.libvirtd.qemu.swtpm.enable = true;
  virtualisation.libvirtd.qemu.ovmf.packages = [ pkgs.OVMFFull.fd ];

  users.users.dacio = {
    isNormalUser = true;
    description = "Dacio";
    group = "dacio";
    uid = 1000;
    extraGroups = [
      "wheel"
      "libvirtd"
    ];
  };
  # Emulate `useradd --user-group`
  users.groups.dacio.gid = 1000;
  home-manager.users.dacio = import ./home.nix;

  system.stateVersion = "22.05";
}
