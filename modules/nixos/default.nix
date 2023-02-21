{
  gnome = import ./gnome.nix;
  home-manager = import ./home-manager.nix;
  mullvad-vpn = import ./mullvad-vpn.nix;
  nix = import ./nix.nix;
  nixpkgs = import ./nixpkgs.nix;
  pc = import ./pc.nix;
  virt-manager = import ./virt-manager.nix;
}
