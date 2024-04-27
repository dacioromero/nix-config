{ pkgs
, inputs
, lib
, config
, ...
}: {
  imports =
    (lib.singleton ./hardware-configuration.nix)
    ++ (lib.attrValues {
      inherit (inputs.self.nixosModules)
        media
        nix
        ;

      inherit (inputs.agenix.nixosModules) age;
    });

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.timeout = 0;

  networking.hostName = "fiyarr";
  networking.useNetworkd = true;

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
  # virtualisation.oci-containers.containers.heimdall = {
  #   image = "lscr.io/linuxserver/heimdall:v2.6.1-ls263";
  #   environment = {
  #     PUID = toString config.users.users.media.uid;
  #     PGID = toString config.users.groups.media.gid;
  #     TZ = config.time.timeZone;
  #   };
  #   volumes = [
  #     "/var/lib/heimdall:/config"
  #   ];
  #   ports = [
  #     "80:80"
  #     "443:443"
  #   ];
  # };
  virtualisation.oci-containers.containers.flaresolverr = {
    image = "ghcr.io/flaresolverr/flaresolverr:v3.3.17";
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

  age.secrets.bitmagnet-env.file = ../../secrets/bitmagnet-env.age;

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
