{ modulesPath, config, inputs, ... }:

{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
    inputs.self.nixosModules.nix
  ];

  time.timeZone = "America/Los_Angeles";

  services.tor = {
    enable = true;
    openFirewall = true;
    relay = {
      enable = true;
      role = "relay";
    };
    settings = {
      Nickname = "firerelay";
      ORPort = [{
        port = 9001;
        IPv4Only = true;
      }];
      BandwidthRate = "250KBytes";
      BandwidthBurst = "500Kbytes";
    };
  };

  services.syncthing.relay = {
    enable = true;
    providedBy = "firerelay";
    globalRateBps = 500000;
  };

  networking.firewall.allowedTCPPorts = [
    config.services.syncthing.relay.port
    config.services.syncthing.relay.statusPort
  ];

  system.stateVersion = "23.11";
}
