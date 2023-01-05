# https://nixos.wiki/wiki/Virt-manager
{pkgs, ...}: {
  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;
  environment.systemPackages = [pkgs.virt-manager];
}
