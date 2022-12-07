# Mullvad needs forced Wayland hints, their script doesn't support Gnome as a compositor
# https://github.com/mullvad/mullvadvpn-app/issues/3062
# https://github.com/mullvad/mullvadvpn-app/blob/9639b2ceab5ec9c7696204e27f5b87dcc09a7a82/dist-assets/linux/mullvad-gui-launcher.sh#L11
# Still will crash if opened from tray on Gnome
# https://github.com/electron/electron/issues/35657
final: prev: {
  mullvad-vpn = prev.symlinkJoin {
    name = "mullvad-vpn";
    paths = [prev.mullvad-vpn];
    buildInputs = [prev.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/mullvad-vpn \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}"
    '';
  };
}
