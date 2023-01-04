{
  pkgs,
  nixos-hardware,
  self,
  ...
}: {
  imports =
    [./hardware-configuration.nix]
    ++ (with nixos-hardware.nixosModules; [
      common-cpu-amd-pstate
      common-gpu-nvidia-nonprime
    ])
    ++ (with self.nixosModules; [base gnome]);

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

  # Experimenting with NixOS on SBCs
  boot.binfmt.emulatedSystems = ["armv7l-linux"];

  # Add more BTRFS mount options
  fileSystems."/".options = ["noatime" "compress=zstd"];
  fileSystems."/nix".options = ["noatime" "compress=zstd"];
  fileSystems."/home".options = ["noatime" "compress=zstd"];
  fileSystems."/boot".options = ["noatime"];

  networking.hostName = "firetower";
  networking.firewall.interfaces.wg-mullvad.allowedTCPPorts = [58651 54846];

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

  services.hardware.openrgb.enable = true;
  services.ratbagd.enable = true;
  services.mullvad-vpn.enable = true;

  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;
  environment.systemPackages = with pkgs; [virt-manager piper mullvad-vpn];

  system.stateVersion = "22.05";
}
