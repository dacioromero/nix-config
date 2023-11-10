{
  users.users.media = {
    uid = 991;
    group = "media";
    isSystemUser = true;
    useDefaultShell = true;
    home = "/media";
  };
  users.groups.media.gid = 989;

  fileSystems."/media" = {
    device = "192.168.1.231:/media";
    fsType = "nfs";
  };
}
