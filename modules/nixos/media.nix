{
  users.users.media = {
    uid = 991;
    group = "media";
    isSystemUser = true;
    createHome = true;
    home = "/home/media";
    homeMode = "700";
    useDefaultShell = true;
  };
  users.groups.media.gid = 989;

  fileSystems."/media" = {
    device = "10.0.30.100:/media";
    fsType = "nfs";
  };
}
