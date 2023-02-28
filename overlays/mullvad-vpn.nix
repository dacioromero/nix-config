final: prev: {
  # Mullvad needs forced Wayland hints because their script doesn't support Gnome as a compositor
  # https://github.com/mullvad/mullvadvpn-app/issues/3062
  # https://github.com/mullvad/mullvadvpn-app/blob/9639b2ceab5ec9c7696204e27f5b87dcc09a7a82/dist-assets/linux/mullvad-gui-launcher.sh#L11
  # Still will crash if opened from tray on Wayland, so we're forcing X11 mode
  # https://github.com/electron/electron/issues/35657
  mullvad-vpn = prev.symlinkJoin {
    name = "mullvad-vpn";
    paths = [ prev.mullvad-vpn ];
    buildInputs = [ prev.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/mullvad-vpn \
        --add-flags "--disable-features=UseOzonePlatform --use-gl=desktop"
      sed -i "s|Exec.*$|Exec=$out/bin/mullvad-vpn %U|" $out/share/applications/mullvad-vpn.desktop
    '';
  };
}
