{ pkgs
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
  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };

  system.stateVersion = "23.05";
}
