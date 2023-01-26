# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  ...
}: let
  authorizedKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQChdVQFQy29aCt5Su4COANlKmtRv1yWmccAjGCd8M0+bxlUqkfS/QDK05NxSDN+9Tzj/ge6myExbXeKbWMrxl6r4Ib5kpB6Db8WpuFmvXqyOc/L8d3ZFcWdn1i2ZYyXgp+ipkZlwYYaDqbaq7e+pfInNHDIirxMrULBy8n6FZo+EpIURhs8fNK8ujLKFQ94P4n+zGv9rwVPetXnYEUis4ro/qKwYzBPKGWQngnFLd0HthWR9MovixOuCe+mHcb1JZeHMOZi8/HfLsho0UfokMjHoQ0wZdQM7VbHjVZUuyhFV1aJHls4FOK67l88kbDUUouDCymgqMXZWYupHyp0LpnhzHm5WfPIkBaQR2InspdaH0mEztQ1iobCmM27A4XfuiAgtpzSPuKYH061kSGuEJGUf762o8Fo70W9pdkkaQx68OCVC99Ccqs7R+FJESHE9IVRmOyzTJKdjG/+LWqCgyv/OeNb7IxEF1Jqwh4D6ZHKb7BX5ccbTgBBRzs71WySFJimSRmuxbzVI4fmzYc1n1dyir/hEZEBpcpKIrryrDz6Hdl4AfwKOwwt9Wnf+aBlA45tbd52ORGgAojOQ+0kLQ1ZjFoyJU26v4WS3cTUMoi71U8Z9KaNHlTFS2msU8YXwQlH5o/r3cnnnRb3ZtEPGm833lDYUxo0+B3JP9J2j1rpnw==";
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./10-pi-hole.nix
    ./20-rfc-8767.nix
    ./99-optimization.nix
  ];

  nix.settings.substituters = ["https://cache.armv7l.xyz"];
  nix.settings.trusted-public-keys = ["cache.armv7l.xyz-1:kBY/eGnBAYiqYfg0fy0inWhshUo+pGFM3Pj7kIkmlBk="];
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.loader.timeout = 1;

  # Needed for large so-rcvbuf and so-sndbuf
  # https://nlnetlabs.nl/documentation/unbound/howto-optimise/
  boot.kernel.sysctl."net.core.rmem_max" = 4194304;
  boot.kernel.sysctl."net.core.wmem_max" = 4194304;

  zramSwap = {
    enable = true;
    algorithm = "lz4";
  };

  services.openssh.enable = true;

  services.blocky.enable = true;
  services.blocky.settings = {
    upstream.default = ["127.0.0.1:5335"];
    blocking = {
      blackLists.ads = ["https://dbl.oisd.nl/"];
      clientGroupsBlock.default = ["ads"];
    };
    httpPort = 4000;
  };

  services.unbound.enable = true;
  services.unbound.resolveLocalQueries = false;

  networking.useDHCP = false;
  networking.nameservers = ["8.8.8.8" "8.8.4.4"];
  networking.defaultGateway = "192.168.1.1";
  networking.interfaces.eth0.ipv4.addresses = [
    {
      address = "192.168.1.2";
      prefixLength = 24;
    }
  ];

  networking.firewall.allowedTCPPorts = [53];
  networking.firewall.allowedUDPPorts = [53];

  networking.hostName = "firepi";

  time.timeZone = "America/Los_Angeles";

  users.users.dacio = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keys = [authorizedKey];
  };

  system.stateVersion = "23.05"; # Did you read the comment?
}
