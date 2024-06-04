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
        media
        nix;

      inherit (inputs.agenix.nixosModules) age;
    });

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "fiyarr-qbt";
  networking.useNetworkd = true;
  networking.useDHCP = false;
  systemd.network.enable = true;
  systemd.network.networks."10-lab" = {
    name = "ens18";
    address = [ "10.0.30.103/24" ];
    gateway = [ "10.0.30.1" ];
    dns = [ "10.0.30.1" ];
  };
  systemd.network.networks."10-airvpn" = {
    name = "wg-air";
    address = [
      "10.165.12.175/32"
      "fd7d:76ee:e68f:a993:5b9c:d651:a000:1ec2/128"
    ];
    dns = [
      "10.128.0.1"
      "fd7d:76ee:e68f:a993::"
    ];
    linkConfig = {
      # AirVPN specified
      MTUBytes = "1320";
    };
    # Make packets routable through this network
    # ipv4 seems routable w/o, ipv6 requires it
    # Similar to wg-quick or networking.wireguard.interfaces.<name>.allowedIPsAsRoutes
    routes = map (r: { routeConfig = r; }) [
      { Destination = "0.0.0.0/0"; }
      { Destination = "::/0"; }
    ];
  };
  age.secrets =
    let
      mkNetworkdSecret = file: {
        inherit file;
        mode = "440";
        owner = "systemd-network";
        group = "systemd-network";
      };
    in
    {
      airvpn-private-key = mkNetworkdSecret ../../secrets/airvpn-private-key.age;
      airvpn-preshared-key = mkNetworkdSecret ../../secrets/airvpn-preshared-key.age;
    };
  systemd.network.netdevs."10-airvpn" = {
    netdevConfig = {
      Kind = "wireguard";
      Name = "wg-air";
    };
    wireguardConfig = {
      PrivateKeyFile = config.age.secrets.airvpn-private-key.path;
    };
    wireguardPeers = [{
      wireguardPeerConfig = {
        PublicKey = "PyLCXAQT8KkM4T+dUsOQfn+Ub3pGxfGlxkIApuig+hk=";
        PresharedKeyFile = config.age.secrets.airvpn-preshared-key.path;
        Endpoint = "us3.vpn.airdns.org:1637";
        AllowedIPs = [ "0.0.0.0/0" "::/0" ];
        # AirVPN specified
        PersistentKeepalive = 15;
      };
    }];
  };
  # Allow port forwarding
  networking.firewall.interfaces."wg-air" = {
    allowedTCPPortRanges = [{
      from = 2048;
      to = 65535;
    }];
    allowedUDPPortRanges = [{
      from = 2048;
      to = 65535;
    }];
  };
  networking.firewall.checkReversePath = "loose";

  time.timeZone = "America/Los_Angeles";
  services.openssh.enable = true;

  services.qemuGuest.enable = true;
  systemd.packages = [ pkgs.qbittorrent-nox ];
  systemd.services."qbittorrent-nox@media" = {
    overrideStrategy = "asDropin";
    wantedBy = [ "multi-user.target" ];
    bindsTo = [ "media.mount" ];
    after = [ "media.mount" ];
  };
  networking.firewall.allowedTCPPorts = [ 8080 ];

  users.users.dacio = {
    isNormalUser = true;
    description = "Dacio";
    uid = 1000;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQChdVQFQy29aCt5Su4COANlKmtRv1yWmccAjGCd8M0+bxlUqkfS/QDK05NxSDN+9Tzj/ge6myExbXeKbWMrxl6r4Ib5kpB6Db8WpuFmvXqyOc/L8d3ZFcWdn1i2ZYyXgp+ipkZlwYYaDqbaq7e+pfInNHDIirxMrULBy8n6FZo+EpIURhs8fNK8ujLKFQ94P4n+zGv9rwVPetXnYEUis4ro/qKwYzBPKGWQngnFLd0HthWR9MovixOuCe+mHcb1JZeHMOZi8/HfLsho0UfokMjHoQ0wZdQM7VbHjVZUuyhFV1aJHls4FOK67l88kbDUUouDCymgqMXZWYupHyp0LpnhzHm5WfPIkBaQR2InspdaH0mEztQ1iobCmM27A4XfuiAgtpzSPuKYH061kSGuEJGUf762o8Fo70W9pdkkaQx68OCVC99Ccqs7R+FJESHE9IVRmOyzTJKdjG/+LWqCgyv/OeNb7IxEF1Jqwh4D6ZHKb7BX5ccbTgBBRzs71WySFJimSRmuxbzVI4fmzYc1n1dyir/hEZEBpcpKIrryrDz6Hdl4AfwKOwwt9Wnf+aBlA45tbd52ORGgAojOQ+0kLQ1ZjFoyJU26v4WS3cTUMoi71U8Z9KaNHlTFS2msU8YXwQlH5o/r3cnnnRb3ZtEPGm833lDYUxo0+B3JP9J2j1rpnw== cardno:17_970_358" ];
  };
  users.users.root.openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQChdVQFQy29aCt5Su4COANlKmtRv1yWmccAjGCd8M0+bxlUqkfS/QDK05NxSDN+9Tzj/ge6myExbXeKbWMrxl6r4Ib5kpB6Db8WpuFmvXqyOc/L8d3ZFcWdn1i2ZYyXgp+ipkZlwYYaDqbaq7e+pfInNHDIirxMrULBy8n6FZo+EpIURhs8fNK8ujLKFQ94P4n+zGv9rwVPetXnYEUis4ro/qKwYzBPKGWQngnFLd0HthWR9MovixOuCe+mHcb1JZeHMOZi8/HfLsho0UfokMjHoQ0wZdQM7VbHjVZUuyhFV1aJHls4FOK67l88kbDUUouDCymgqMXZWYupHyp0LpnhzHm5WfPIkBaQR2InspdaH0mEztQ1iobCmM27A4XfuiAgtpzSPuKYH061kSGuEJGUf762o8Fo70W9pdkkaQx68OCVC99Ccqs7R+FJESHE9IVRmOyzTJKdjG/+LWqCgyv/OeNb7IxEF1Jqwh4D6ZHKb7BX5ccbTgBBRzs71WySFJimSRmuxbzVI4fmzYc1n1dyir/hEZEBpcpKIrryrDz6Hdl4AfwKOwwt9Wnf+aBlA45tbd52ORGgAojOQ+0kLQ1ZjFoyJU26v4WS3cTUMoi71U8Z9KaNHlTFS2msU8YXwQlH5o/r3cnnnRb3ZtEPGm833lDYUxo0+B3JP9J2j1rpnw== cardno:17_970_358" ];

  system.stateVersion = "23.05";
}
