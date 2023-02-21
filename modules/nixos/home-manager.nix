{inputs, ...}: {
  # imports = [inputs.home-manager.nixosModules.home-manager];
  home-manager.extraSpecialArgs = {inherit inputs;};
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
}
