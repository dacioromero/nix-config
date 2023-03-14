{ inputs, ... }:
let
  inherit (inputs) self;
  # TODO: Consider separating into its own file
  authorizedKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQChdVQFQy29aCt5Su4COANlKmtRv1yWmccAjGCd8M0+bxlUqkfS/QDK05NxSDN+9Tzj/ge6myExbXeKbWMrxl6r4Ib5kpB6Db8WpuFmvXqyOc/L8d3ZFcWdn1i2ZYyXgp+ipkZlwYYaDqbaq7e+pfInNHDIirxMrULBy8n6FZo+EpIURhs8fNK8ujLKFQ94P4n+zGv9rwVPetXnYEUis4ro/qKwYzBPKGWQngnFLd0HthWR9MovixOuCe+mHcb1JZeHMOZi8/HfLsho0UfokMjHoQ0wZdQM7VbHjVZUuyhFV1aJHls4FOK67l88kbDUUouDCymgqMXZWYupHyp0LpnhzHm5WfPIkBaQR2InspdaH0mEztQ1iobCmM27A4XfuiAgtpzSPuKYH061kSGuEJGUf762o8Fo70W9pdkkaQx68OCVC99Ccqs7R+FJESHE9IVRmOyzTJKdjG/+LWqCgyv/OeNb7IxEF1Jqwh4D6ZHKb7BX5ccbTgBBRzs71WySFJimSRmuxbzVI4fmzYc1n1dyir/hEZEBpcpKIrryrDz6Hdl4AfwKOwwt9Wnf+aBlA45tbd52ORGgAojOQ+0kLQ1ZjFoyJU26v4WS3cTUMoi71U8Z9KaNHlTFS2msU8YXwQlH5o/r3cnnnRb3ZtEPGm833lDYUxo0+B3JP9J2j1rpnw==";
in
{
  imports =
    [ ./hardware-configuration.nix ]
    ++ (with self.nixosModules; [
      nix
      nixpkgs
    ]);

  # Found Hydra build server on nixos.wiki
  # https://hydra.armv7l.xyz/ https://gitlab.com/misuzu/hydra-armv7l
  nix.settings.substituters = [ "https://cache.armv7l.xyz" ];
  nix.settings.trusted-public-keys = [ "cache.armv7l.xyz-1:kBY/eGnBAYiqYfg0fy0inWhshUo+pGFM3Pj7kIkmlBk=" ];

  # Builder error: "hash mismatch in fixed-output derivation"
  nixpkgs.overlays = [
    (final: prev: {
      docker = prev.docker.override {
        composeSupport = false;
      };
    })
  ];

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;
  # Faster boot for server infrastructure
  boot.loader.timeout = 1;

  # BPi has 512MB of RAM, needs compression to not crash
  zramSwap.enable = true;
  # Allwinner H3 is slow
  zramSwap.algorithm = "lz4";

  networking.hostName = "firepi";
  networking.useDHCP = false;
  networking.useNetworkd = true;
  networking.interfaces.eth0.useDHCP = true;
  networking.firewall.allowedTCPPorts = [ 8123 ];
  services.openssh.enable = true;
  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "server";

  time.timeZone = "America/Los_Angeles";

  users.users.root.openssh.authorizedKeys.keys = [ authorizedKey ];
  users.users.dacio = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    openssh.authorizedKeys.keys = [ authorizedKey ];
  };

  virtualisation.oci-containers = {
    # Using docker instead of podman do to compile error
    # https://github.com/containers/netavark/issues/578
    backend = "docker";
    containers.homeassistant = {
      volumes = [ "home-assistant:/config" ];
      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "America/Los_Angeles";
      };
      image = "lscr.io/linuxserver/homeassistant:2023.3.3";
      extraOptions = [ "--network=host" ];
    };
  };

  system.stateVersion = "23.05";
}
