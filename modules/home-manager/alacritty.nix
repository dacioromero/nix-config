{ inputs, ... }: {
  programs.alacritty = {
    enable = true;
    settings = {
      import = [ "${inputs.omni-alacritty}/omni.yml" ];
      font =
        let
          mkFace = style: {
            family = "JetBrainsMono Nerd Font";
            inherit style;
          };
        in
        {
          normal = mkFace "Regular";
          bold = mkFace "Bold";
          italic = mkFace "Italic";
          bold_italic = mkFace "Bold Italic";
          size = 12;
        };
      window = rec {
        padding.x = 12;
        padding.y = padding.x;
        opacity = 0.95;
      };
      cursor.style.blinking = "On";
      key_bindings = [
        {
          key = "N";
          mods = "Control";
          action = "SpawnNewInstance";
        }
      ];
    };
  };
}
