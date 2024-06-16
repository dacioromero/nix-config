{ pkgs
, inputs
, lib
, config
, ...
}:
let
  # Public subnets to prevent routing LAN traffic through Wireguard
  # https://airvpn.org/forums/topic/55801-wireguard-access-local-network/?do=findComment&comment=217458
  publicSubnets = [
    "0.0.0.0/5"
    "8.0.0.0/7"
    "11.0.0.0/8"
    "12.0.0.0/6"
    "16.0.0.0/4"
    "32.0.0.0/3"
    "64.0.0.0/2"
    "128.0.0.0/3"
    "160.0.0.0/5"
    "168.0.0.0/6"
    "172.0.0.0/12"
    "172.32.0.0/11"
    "172.64.0.0/10"
    "172.128.0.0/9"
    "173.0.0.0/8"
    "174.0.0.0/7"
    "176.0.0.0/4"
    "192.0.0.0/9"
    "192.128.0.0/11"
    "192.160.0.0/13"
    "192.169.0.0/16"
    "192.170.0.0/15"
    "192.172.0.0/14"
    "192.176.0.0/12"
    "192.192.0.0/10"
    "193.0.0.0/8"
    "194.0.0.0/7"
    "196.0.0.0/6"
    "200.0.0.0/5"
    "208.0.0.0/4"
    "224.0.0.0/3"
    "::/1"
    "8000::/2"
    "c000::/3"
    "e000::/4"
    "f000::/5"
    "f800::/6"
    "fc00::/8"
    "fe00::/7"
  ];
in
{
  imports =
    (lib.singleton ./hardware-configuration.nix)
    ++ (lib.attrValues {
      inherit (inputs.self.nixosModules)
        media-user
        media-mount
        nix
        ;

      inherit (inputs.agenix.nixosModules) age;
    });

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "fiyarr";
  networking.useNetworkd = true;
  networking.useDHCP = false;
  systemd.network.enable = true;
  systemd.network.netdevs."10-mac0" = {
    netdevConfig = {
      Kind = "macvlan";
      Name = "mac0";
    };
    macvlanConfig = {
      Mode = "bridge";
    };
  };
  systemd.network.networks."10-mac0-ens18" = {
    name = "ens18";
    macvlan = [ "mac0" ];
  };
  systemd.network.networks."10-lab" = {
    name = "mac0";
    address = [ "10.0.30.101/24" ];
    gateway = [ "10.0.30.1" ];
    dns = [ "10.0.30.1" ];
  };
  systemd.network.networks."10-airvpn" = {
    name = "wg-air";
    address = [
      "10.134.3.52/32"
      "fd7d:76ee:e68f:a993:78cd:d7af:e091:bdd3/128"
    ];
    dns = [
      "10.128.0.1"
      "fd7d:76ee:e68f:a993::1"
    ];
    linkConfig = {
      # AirVPN specified
      MTUBytes = "1320";
    };
    # Make packets routable through this network
    # ipv4 seems routable w/o, ipv6 requires it
    # Similar to wg-quick or networking.wireguard.interfaces.<name>.allowedIPsAsRoutes
    routes = map (Destination: { inherit Destination; Table = 8677; }) publicSubnets;
    # Route bitmagnet through Wireguard
    # https://wiki.archlinux.org/title/WireGuard#systemd-networkd:_routing_all_traffic_over_WireGuard
    routingPolicyRules = [
      {
        Table = 8677;
        User = "bitmagnet";
        Priority = 30001;
        Family = "both";
      }
      {
        Table = "main";
        User = "bitmagnet";
        SuppressPrefixLength = 0;
        Priority = 30000;
        Family = "both";
      }
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
      airvpn-private-key = mkNetworkdSecret ../../secrets/airvpn-fiyarr-sk.age;
      airvpn-preshared-key = mkNetworkdSecret ../../secrets/airvpn-fiyarr-psk.age;
      bitmagnet-env.file = ../../secrets/bitmagnet-env.age;
    };
  systemd.network.netdevs."10-airvpn" = {
    netdevConfig = {
      Kind = "wireguard";
      Name = "wg-air";
    };
    wireguardConfig = {
      PrivateKeyFile = config.age.secrets.airvpn-private-key.path;
      RouteTable = 8677;
    };
    wireguardPeers = [{
      PublicKey = "PyLCXAQT8KkM4T+dUsOQfn+Ub3pGxfGlxkIApuig+hk=";
      PresharedKeyFile = config.age.secrets.airvpn-preshared-key.path;
      Endpoint = "us3.vpn.airdns.org:1637";
      AllowedIPs = publicSubnets;
      # AirVPN specified
      PersistentKeepalive = 15;
    }];
  };

  networking.firewall.checkReversePath = "loose";

  time.timeZone = "America/Los_Angeles";
  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [
    recyclarr
    intel-gpu-tools # intel_gpu_top
    bitmagnet
  ];

  services.qemuGuest.enable = true;

  virtualisation.podman.autoPrune = {
    enable = true;
    flags = [ "--all" ];
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = "media";
    group = "media";
  };
  systemd.services.jellyfin.after = [ "media.mount" ];
  systemd.services.jellyfin.bindsTo = [ "media.mount" ];
  hardware.opengl.enable = true;
  hardware.opengl.extraPackages = with pkgs; [
    intel-media-driver
    intel-compute-runtime
  ];
  virtualisation.oci-containers.containers.flaresolverr = {
    image = "ghcr.io/flaresolverr/flaresolverr:v3.3.19";
    environment = {
      TZ = config.time.timeZone;
    };
    ports = [ "8191:8191" ];
  };
  networking.firewall.allowedTCPPorts = [
    80
    443
    3333
  ];
  services.sonarr = {
    enable = true;
    openFirewall = true;
    user = "media";
    group = "media";
  };
  systemd.services.sonarr.after = [ "media.mount" ];
  systemd.services.sonarr.bindsTo = [ "media.mount" ];
  services.radarr = {
    enable = true;
    openFirewall = true;
    user = "media";
    group = "media";
  };
  systemd.services.radarr.after = [ "media.mount" ];
  systemd.services.radarr.bindsTo = [ "media.mount" ];
  services.lidarr = {
    enable = true;
    openFirewall = true;
    user = "media";
    group = "media";
  };
  systemd.services.lidarr.after = [ "media.mount" ];
  systemd.services.lidarr.bindsTo = [ "media.mount" ];
  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };
  services.jellyseerr = {
    enable = true;
    openFirewall = true;
  };

  containers."media-4k" = {
    autoStart = true;
    macvlans = [ "mac0" ];
    bindMounts.media = {
      isReadOnly = false;
      hostPath = "/media";
      mountPoint = "/media";
    };
    config = {
      imports = lib.singleton inputs.self.nixosModules.media-user;

      networking.useHostResolvConf = lib.mkForce false;
      networking.useNetworkd = true;
      systemd.network.enable = true;
      systemd.network.networks."10-lab" = {
        name = "mv-mac0";
        address = [ "10.0.30.201/24" ];
        gateway = [ "10.0.30.1" ];
        dns = [ "10.0.30.1" ];
      };

      # services.sonarr = {
      #   enable = true;
      #   openFirewall = true;
      #   user = "media";
      #   group = "media";
      # };

      services.radarr = {
        enable = true;
        openFirewall = true;
        user = "media";
        group = "media";
      };

      system.stateVersion = "24.11";
    };
  };
  systemd.services."container@media-4k" = {
    after = [ "media.mount" ];
    bindsTo = [ "media.mount" ];
  };

  containers."media-anime" = {
    autoStart = true;
    macvlans = [ "mac0" ];
    bindMounts.media = {
      isReadOnly = false;
      hostPath = "/media";
      mountPoint = "/media";
    };
    config = {
      imports = lib.singleton inputs.self.nixosModules.media-user;

      networking.useHostResolvConf = lib.mkForce false;
      networking.useNetworkd = true;
      systemd.network.enable = true;
      systemd.network.networks."10-lab" = {
        name = "mv-mac0";
        address = [ "10.0.30.202/24" ];
        gateway = [ "10.0.30.1" ];
        dns = [ "10.0.30.1" ];
      };

      services.sonarr = {
        enable = true;
        openFirewall = true;
        user = "media";
        group = "media";
      };

      services.radarr = {
        enable = true;
        openFirewall = true;
        user = "media";
        group = "media";
      };

      system.stateVersion = "24.11";
    };
  };
  systemd.services."container@media-anime" = {
    after = [ "media.mount" ];
    bindsTo = [ "media.mount" ];
  };

  # TODO: Upstream into module?
  environment.etc."xdg/bitmagnet/config.yml".text = builtins.toJSON {
    postgres.host = "/run/postgresql/";
    postgres.user = "bitmagnet";
  };
  users.users.bitmagnet = {
    isSystemUser = true;
    group = "bitmagnet";
  };
  users.groups.bitmagnet = { };
  systemd.services.bitmagnet = {
    description = "Bitmagnet";
    serviceConfig = {
      Type = "exec";
      ExecStart = "${lib.getExe pkgs.bitmagnet} worker run --keys=http_server --keys=queue_server --keys=dht_crawler";
      EnvironmentFile = config.age.secrets.bitmagnet-env.path;
      Restart = "on-failure";
      User = "bitmagnet";
      Group = "bitmagnet";
    };
    wantedBy = [ "multi-user.target" ];
  };
  services.postgresql.enable = true;
  services.postgresql.ensureDatabases = [ "bitmagnet" ];
  services.postgresql.ensureUsers = [{
    name = "bitmagnet";
    ensureDBOwnership = true;
  }];

  services.nginx = {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."jf.dacio.app" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8096";
        proxyWebsockets = true;
      };
    };

    virtualHosts."js.dacio.app" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:5055";
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "dacioromero@gmail.com";
  };

  # Needed for VSCode server
  programs.nix-ld.enable = true;

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
