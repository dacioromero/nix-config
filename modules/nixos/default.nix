{
  base = import ./base.nix;
  gnome = import ./gnome.nix;
  hm = import ./hm.nix;
  kde = import ./kde.nix;
  media = import ./media.nix;
  nix = import ./nix.nix;
  nixpkgs = import ./nixpkgs.nix;
  pc = import ./pc.nix;
  pipewire = import ./pipewire.nix;
  syncthing-firewall = import ./syncthing-firewall.nix;
  virt-manager = import ./virt-manager.nix;
  xwaylandvideobridge = import ./xwaylandvideobridge.nix;
  zram = import ./zram.nix;
}
