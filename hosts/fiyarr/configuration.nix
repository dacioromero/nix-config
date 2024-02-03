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
        base
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
  hardware.opengl.enable = true;
  hardware.opengl.extraPackages = with pkgs; [
    intel-media-driver
    intel-compute-runtime
  ];
  virtualisation.oci-containers.containers.sonarr = {
    image = "lscr.io/linuxserver/sonarr:4.0.1.929-ls224";
    environment = {
      PUID = toString config.users.users.media.uid;
      PGID = toString config.users.groups.media.gid;
      TZ = config.time.timeZone;
    };
    volumes = [
      "/var/lib/sonarr-container:/config"
      "/media:/media"
    ];
    ports = [ "8989:8989" ];
  };
  virtualisation.oci-containers.containers.heimdall = {
    image = "lscr.io/linuxserver/heimdall:V2.5.8-ls250";
    environment = {
      PUID = toString config.users.users.media.uid;
      PGID = toString config.users.groups.media.gid;
      TZ = config.time.timeZone;
    };
    volumes = [
      "/var/lib/heimdall:/config"
    ];
    ports = [
      "80:80"
      "443:443"
    ];
  };
  virtualisation.oci-containers.containers.flaresolverr = {
    image = "ghcr.io/flaresolverr/flaresolverr:v3.3.13";
    environment = {
      TZ = config.time.timeZone;
    };
    ports = [ "8191:8191" ];
  };
  networking.firewall.allowedTCPPorts = [
    8989
    80
    443
    3333
  ];
  services.radarr = {
    enable = true;
    openFirewall = true;
    user = "media";
    group = "media";
  };
  services.lidarr = {
    enable = true;
    openFirewall = true;
    user = "media";
    group = "media";
  };
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
  # TODO: Figure out security
  services.redis.servers."".enable = true;

  # Needed for VSCode server
  programs.nix-ld.enable = true;

  age.secrets.bitmagnet-env.file = ../../secrets/bitmagnet-env.age;

  system.stateVersion = "23.05";
}
