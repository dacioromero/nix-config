{
  # Syncthing ports
  # https://github.com/NixOS/nixpkgs/blob/dc1834e25c1fce8df4be1938efb6166c7fa69eb1/nixos/modules/services/networking/syncthing.nix#L602C1-L605
  networking.firewall.allowedTCPPorts = [ 22000 ];
  networking.firewall.allowedUDPPorts = [ 21027 22000 ];
}
