# https://github.com/SpacingBat3/WebCord/issues/240
final: prev: {
  webcord = prev.webcord.override { electron_22 = prev.electron_23; };
}
