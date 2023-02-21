{
  pkgs,
  inputs,
  ...
}: {
  imports =
    [
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.home-manager
    ]
    ++ (with inputs.nixos-hardware.nixosModules; [lenovo-thinkpad-x1-6th-gen])
    ++ (with inputs.self.nixosModules; [
      nix
      nixpkgs
      pc
      gnome
      mullvad-vpn
      virt-manager
      home-manager
    ]);

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.supportedFilesystems = ["ntfs"];

  boot.plymouth.enable = true;
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

  services.fwupd.enable = true;
  services.printing.drivers = [pkgs.hplipWithPlugin];

  programs.adb.enable = true;

  users.users.dacio = {
    isNormalUser = true;
    description = "Dacio";
    group = "dacio";
    uid = 1000;
    extraGroups = ["wheel" "adbusers" "networkmanager"];
  };

  services.jellyfin.enable = true;
  services.jellyfin.openFirewall = true;
  services.tailscale.enable = true;

  users.groups.dacio.gid = 1000;
  home-manager.users.dacio = import ./home.nix;

  system.stateVersion = "22.11";
}
