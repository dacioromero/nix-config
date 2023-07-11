{ pkgs
, inputs
, config
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
    [
      ./hardware-configuration.nix
      lanzaboote.nixosModules.lanzaboote
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

  # Many distros enable this by default
  # https://www.kernel.org/doc/html/next/admin-guide/sysctl/vm.html
  # https://haydenjames.io/linux-performance-almost-always-add-swap-part2-zram/
  # https://www.reddit.com/r/Fedora/comments/mzun99/new_zram_tuning_benchmarks/
  # https://github.com/pop-os/default-settings/pull/163
  # https://github.com/AlexMekkering/Arch-Linux/blob/master/docs/installation/optimizations.md
  zramSwap.enable = true;
  zramSwap.memoryPercent = 100;
  # zram is relatively cheap, prefer swap
  boot.kernel.sysctl."vm.swappiness" = 180;
  # zram is in memory, no need to readahead
  boot.kernel.sysctl."vm.page-cluster" = 0;
  # Start asynchronously writing at 128 MiB dirty memory
  boot.kernel.sysctl."vm.dirty_background_bytes" = 128 * 1024 * 1024;
  # Start synchronously writing at 50% dirty memory
  # boot.kernel.sysctl."vm.dirty_ratio" = 50;
  boot.kernel.sysctl."vm.dirty_bytes" = 64 * 1024 * 1024;
  boot.kernel.sysctl."vm.vfs_cache_pressure" = 500;

  # With 32 GiB of RAM and zram enabled OOM is unlikely
  systemd.oomd.enable = false;
  # systemd.services.NetworkManager-wait-online.enable = false;
  systemd.network.wait-online.enable = false;

  networking.hostName = "firetower";
  networking.firewall.interfaces.wg-mullvad.allowedTCPPorts = [ 58651 ];
  networking.firewall.interfaces.br0.allowedTCPPorts = [ 25565 24070 ];

  networking.useDHCP = false;
  # networking.interfaces.enp5s0.useDHCP = true;
  # Bridging so VMs can get IPs on LAN subnet
  networking.interfaces.br0.useDHCP = true;
  networking.interfaces.br0.ipv4.addresses = [
    {
      address = "192.168.2.2";
      prefixLength = 24;
    }
  ];
  networking.bridges.br0.interfaces = [ "enp5s0" ];
  # Gnome enables NM by default
  networking.networkmanager.enable = false;
  networking.useNetworkd = true;
  # sd-resolved stub fails on AAA requests, prefer uplink
  # environment.etc."resolv.conf".source = lib.mkForce "/run/systemd/resolve/resolv.conf";
  services.resolved.enable = false;
  services.dnsmasq.enable = true;
  services.dnsmasq.settings.server = [ "192.168.1.1" ];

  time.timeZone = "America/Los_Angeles";

  # Configure GPU
  # Early KMS isn't helpful
  hardware.amdgpu.loadInInitrd = false;
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
  # https://github.com/sibradzic/amdgpu-clocks/blob/master/amdgpu-clocks.service
  systemd.services.amdgpu-overclock = {
    description = "Overclock AMD GPU";
    after = [ "suspend.target" "multi-user.target" "systemd-user-sessions.service" ];
    wantedBy = [ "sleep.target" "multi-user.target" ];
    wants = [ "modprobe@amdgpu.service" ];
    script =
      let
        gpuDevice = "/sys/devices/pci0000:00/0000:00:03.1/0000:09:00.0/0000:0a:00.0/0000:0b:00.0";
      in
      ''
        echo '293000000' > ${gpuDevice}/hwmon/hwmon5/power1_cap # max power limit to 293 W
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

  # Gaming
  programs.gamemode.enable = true;
  programs.steam.enable = true;
  programs.steam.remotePlay.openFirewall = true;

  # Home printer drivers
  services.printing.drivers = [ pkgs.hplipWithPlugin ];

  # Mouse settings
  services.ratbagd.enable = true;
  environment.systemPackages = [ pkgs.piper ];

  # SSH server, needed for remote building
  services.openssh.enable = true;

  # Private VPN
  services.tailscale.enable = true;

  # Enable secure boot and TPM for VMs
  virtualisation.libvirtd.qemu.swtpm.enable = true;
  virtualisation.libvirtd.qemu.ovmf.packages = [ pkgs.OVMFFull.fd ];

  programs.adb.enable = true;

  # Distributed builds host
  nix.settings.trusted-users = [ "builder" ];
  users.users.builder = {
    isSystemUser = true;
    useDefaultShell = true;
    description = "Builder";
    group = "builder";
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDYoOl+yGVCSZgIIazlklT0xGf/phC0rkprT35UOYYZ9JDfqsyij6dl/GSdJ+U9nxznxU0Ls8Ju5S5/F6L+OCeVSDF5omhs6e3uraaYkxIi91eu/rbrrbs2SHbdMcB+8RgvWI/SCe1r+NndDiA+LC97hy8Zop3yjU3ajfH2VcBN6FZbZZhDUVZkmNVOflDAq78+0PEgduXFwy31qgx/b8AvbbGWq7NyrJocD5BEoFePY2kZYtngDMrVqp3U+g/2GUzc7PxqrD7WKVnyLW0zi+ZmA/wAM+SU2ldM/YsXM3yWGI/kg6RtdjWl2N6FBUc0VFdRmuhc/5/YK+LeOeWSBhmQ7HXKx0Bv5BpWi19P/0O3YuXD+3KI6ouepREGNG1cqicne3Eb8LgIgo4UTpLaog4wzbwsot/wIlUJVZc2ZIyBKKpj+omTqh8SgKPMg4CLeZxLIi71bxcMz5W6TrSXmrh1QIjZYG1ntXzKqaaIa+db2VJEAtGn7zRkoZtaaBI71jc= root@firetower" ];
  };
  users.groups.builder = { };

  users.users.dacio = {
    isNormalUser = true;
    description = "Dacio";
    group = "dacio";
    uid = 1000;
    extraGroups = [
      "wheel"
      # "networkmanager"
      "libvirtd"
      "adbusers"
    ];
  };
  # Emulate `useradd --user-group`
  users.groups.dacio.gid = 1000;
  home-manager.users.dacio = import ./home.nix;

  system.stateVersion = "22.05";
}
