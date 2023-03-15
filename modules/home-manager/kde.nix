{ config, ... }: {
  services.gpg-agent.pinentryFlavor = "qt";

  # Activate session variables in KDE Plasma
  # https://github.com/nix-community/home-manager/issues/1011
  xdg.configFile."plasma-workspace/env/hm-session-vars.sh".text = ''
    . "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"
  '';
}
