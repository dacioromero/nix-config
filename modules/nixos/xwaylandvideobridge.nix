# https://github.com/luisnquin/nixos-config/blob/11cecbc16ed588216f77a42769b499bc91bd33a1/home/services/xwaylandvideobridge.nix
{ pkgs
, lib
, ...
}: {
  systemd.user.services = {
    xwaylandvideobridge = {
      description = "Tool to make it easy to stream wayland windows and screens to existing applications running under Xwayland";

      serviceConfig = {
        Type = "simple";
        ExecStart = lib.getExe pkgs.xwaylandvideobridge;
        Restart = "on-failure";
      };

      wantedBy = [ "default.target" ];
    };
  };
}
