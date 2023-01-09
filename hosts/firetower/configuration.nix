{
  pkgs,
  inputs,
  ...
}: {
  imports =
    [./hardware-configuration.nix]
    ++ (with inputs.nixos-hardware.nixosModules; [
      common-cpu-amd-pstate
      common-gpu-nvidia-nonprime
    ])
    ++ (with inputs.self.nixosModules; [
      base
      gnome
      mullvad-vpn
      virt-manager
      home-manager
    ]);

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.supportedFilesystems = ["ntfs"];

  # Silence
  boot.initrd.verbose = false;
  boot.consoleLogLevel = 0;
  boot.kernelParams = [
    "quiet"
    "udev.log_level=3"
    "nvidia.NVreg_TemporaryFilePath=/var/tmp" # Nvidia recommends non-tmpfs
  ];

  # Add more BTRFS mount options
  fileSystems."/".options = ["noatime" "compress=zstd"];
  fileSystems."/nix".options = ["noatime" "compress=zstd"];
  fileSystems."/home".options = ["noatime" "compress=zstd"];
  fileSystems."/boot".options = ["noatime"];

  networking.hostName = "firetower";
  networking.firewall.interfaces.wg-mullvad.allowedTCPPorts = [58651 54846];
  networking.firewall.interfaces.enp4s0.allowedTCPPorts = [25565];

  time.timeZone = "America/Los_Angeles";

  # Configure Nvidia
  hardware.opengl.driSupport32Bit = true;
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.powerManagement.enable = true;

  # Adapted from https://wiki.archlinux.org/title/kexec#No_kernel_mode-setting_(Nvidia)
  systemd.services.unmodeset = {
    description = "Unload nvidia modesetting modules from kernel";
    documentation = ["man:modprobe(8)"];
    unitConfig.DefaultDependencies = "no";
    after = ["umount.target"];
    before = ["kexec.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.kmod}/bin/modprobe -r nvidia_drm";
    };
    wantedBy = ["kexec.target"];
  };

  # Gaming
  programs.gamemode.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  services.printing.drivers = [pkgs.hplipWithPlugin];
  services.hardware.openrgb.enable = true;
  services.ratbagd.enable = true;

  environment.systemPackages = [pkgs.piper];
  environment.gnome.excludePackages = [pkgs.gnome.gnome-software];

  users.users.dacio = {
    isNormalUser = true;
    description = "Dacio";
    group = "dacio";
    uid = 1000;
    extraGroups = ["wheel"];
  };

  users.groups.dacio.gid = 1000;
  home-manager.users.dacio = import ./home.nix;

  system.stateVersion = "22.05";
}
