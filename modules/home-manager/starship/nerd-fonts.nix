{
  config,
  pkgs,
  lib,
  ...
}: let
  starshipNerdFont = pkgs.runCommand "starship-nerd-font" {STARSHIP_CACHE = "/tmp";} ''
    ${config.programs.starship.package}/bin/starship preset nerd-font-symbols > $out
  '';
in {
  programs.starship.settings = builtins.fromTOML (builtins.readFile starshipNerdFont);
}
