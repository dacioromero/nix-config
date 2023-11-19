{ config, pkgs, inputs, ... }: {
  imports =
    [
      ./hardware-configuration.nix
      inputs.self.nixosModules.media
      inputs.self.nixosModules.nix
    ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.timeout = 0;

  networking.hostName = "fiyarr-qbt";
  networking.useNetworkd = true;
  networking.firewall.interfaces.wg0.allowedTCPPortRanges = [{
    from = 2048;
    to = 65535;
  }];

  time.timeZone = "America/Los_Angeles";
  services.openssh.enable = true;

  services.qemuGuest.enable = true;
  systemd.packages = with pkgs; [
    qbittorrent-nox
    wireguard-tools
  ];
  systemd.services."qbittorrent-nox@media" = {
    overrideStrategy = "asDropin";
    wantedBy = [ "multi-user.target" ];
    bindsTo = [ "media.mount" ];
    after = [ "media.mount" ];
  };
  systemd.services."wg-quick@wg0" = {
    overrideStrategy = "asDropin";
    wantedBy = [ "multi-user.target" ];
    path = [
      pkgs.wireguard-tools
      config.networking.firewall.package # iptables or nftables
      config.networking.resolvconf.package # openresolv or systemd
    ];
  };
  networking.firewall.allowedTCPPorts = [ 8080 ];

  system.stateVersion = "23.05";

}

