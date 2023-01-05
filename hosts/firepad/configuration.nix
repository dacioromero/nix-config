{
  pkgs,
  nixos-hardware,
  self,
  lib,
  ...
}: {
  imports =
    [./hardware-configuration.nix]
    ++ (with nixos-hardware.nixosModules; [lenovo-thinkpad-x1-6th-gen])
    ++ (with self.nixosModules; [base gnome]);

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.supportedFilesystems = ["ntfs"];
  boot.plymouth.enable = true;
  boot.plymouth.theme = "breeze";
  boot.initrd.systemd.enable = true;

  # Silence
  boot.initrd.verbose = false;
  boot.consoleLogLevel = 0;
  boot.kernelParams = [
    "quiet"
    "udev.log_level=3"
  ];

  # Add more BTRFS mount options
  fileSystems."/".options = ["noatime" "compress=zstd"];
  fileSystems."/nix".options = ["noatime" "compress=zstd"];
  fileSystems."/home".options = ["noatime" "compress=zstd"];
  fileSystems."/boot".options = ["noatime"];

  networking.hostName = "firepad";
  networking.firewall.interfaces.wg-mullvad.allowedTCPPorts = [54918];

  time.timeZone = "America/Los_Angeles";

  services.mullvad-vpn.enable = true;
  services.fwupd.enable = true;

  services.printing.drivers = [pkgs.hplipWithPlugin];
  hardware.sane.extraBackends = [pkgs.hplipWithPlugin];
  # Prevent poorly auto-discovered ghost printers
  systemd.services.cups-browsed.enable = false;

  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;
  environment.systemPackages = with pkgs; [virt-manager mullvad-vpn firefox];

  system.stateVersion = "22.11";
}
