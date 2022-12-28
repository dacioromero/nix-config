{
  config,
  pkgs,
  nixos-hardware,
  self,
  nixpkgs,
  ...
}: {
  imports =
    [./hardware-configuration.nix]
    ++ (with nixos-hardware.nixosModules; [lenovo-thinkpad-x1-6th-gen])
    ++ (with self.nixosModules; [base gnome]);

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = builtins.attrValues self.overlays;
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.registry.nixpkgs.flake = nixpkgs;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.supportedFilesystems = ["ntfs"];

  networking.hostName = "firepad";

  time.timeZone = "America/Los_Angeles";

  services.mullvad-vpn.enable = true;

  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;
  environment.systemPackages = with pkgs; [virt-manager mullvad-vpn firefox];

  system.stateVersion = "22.11";
}
