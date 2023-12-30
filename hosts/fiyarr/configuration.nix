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
    });

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.timeout = 0;

  networking.hostName = "fiyarr";
  networking.useNetworkd = true;

  time.timeZone = "America/Los_Angeles";
  services.openssh.enable = true;

  environment.systemPackages = [ pkgs.recyclarr ];

  services.qemuGuest.enable = true;
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
    image = "lscr.io/linuxserver/sonarr:develop-4.0.0.738-ls17";
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
    image = "lscr.io/linuxserver/heimdall:V2.5.8-ls245";
    environment = {
      PUID = toString config.users.users.media.uid;
      PGID = toString config.users.groups.media.gid;
      TZ = config.time.timeZone;
    };
    volumes = [
      "/var/lib/heimdall:/config"
      "/media:/media"
    ];
    ports = [
      "80:80"
      "443:443"
    ];
  };
  virtualisation.oci-containers.containers.flaresolverr = {
    image = "ghcr.io/flaresolverr/flaresolverr:v3.3.12";
    environment = {
      TZ = config.time.timeZone;
    };
    ports = [ "8191:8191" ];
  };
  networking.firewall.allowedTCPPorts = [
    8989
    80
    443
  ];
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
  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };

  system.stateVersion = "23.05";
}
