{ config
, pkgs
, ...
}:
let
  # Redirect logging to /tmp to prevent Starship from logging to /nix
  starshipNerdFont = pkgs.runCommand "starship-nerd-font.toml" { STARSHIP_CACHE = "/tmp"; } ''
    ${config.programs.starship.package}/bin/starship preset nerd-font-symbols > $out
  '';
in
{
  programs.starship.settings = builtins.fromTOML (builtins.readFile starshipNerdFont);
}
