# Aggresively setting Electron apps w/ tray to 23 to fix tray
# https://github.com/electron/electron/issues/35657
final: prev: {
  # https://github.com/SpacingBat3/WebCord/issues/240
  webcord = prev.webcord.override { electron_22 = prev.electron_23; };
  # https://github.com/vector-im/element-web/issues/23202
  element-desktop = prev.element-desktop.override { electron = prev.electron_23; };
}
