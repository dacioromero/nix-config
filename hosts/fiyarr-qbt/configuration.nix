{ config
, pkgs
, inputs
, lib
, ...
}: {
  imports =
    (lib.singleton ./hardware-configuration.nix)
    ++ (lib.attrValues {
      inherit (inputs.self.nixosModules)
        base
        media
        nix;
    });

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.timeout = 0;

  networking.hostName = "fiyarr-qbt";
  networking.useNetworkd = true;
  networking.firewall.interfaces.wg0 = {
    allowedTCPPortRanges = [{
      from = 2048;
      to = 65535;
    }];
    allowedUDPPortRanges = [{
      from = 2048;
      to = 65535;
    }];
  };

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
  # https://github.com/NixOS/nixpkgs/blob/b6766564edd0966cd9dc3c4ba4baaffc9413d9a0/nixos/modules/services/networking/wg-quick.nix
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
