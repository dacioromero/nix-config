{
  discord = import ./discord.nix;
  mullvad-vpn = import ./mullvad-vpn.nix;
  pkgs = final: prev: import ../pkgs {pkgs = prev;};
}
