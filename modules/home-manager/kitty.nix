{ inputs, ... }: {
  programs.kitty = {
    enable = true;
    extraConfig = builtins.readFile "${inputs.omni-kitty}/omni.conf";
    font.name = "JetBrainsMono Nerd Font";
    font.size = 12;
    settings = {
      window_padding_width = 12;
      background_opacity = "0.95";
      macos_colorspace = "displayp3";
      # Alacritty dim factor is 0.66
      # Alacritty theme colors
      # normal -> dim = 95/191 = 0.497382199
      # bright -> dim = 95/230 = 0.4130434783
      dim_opacity = "0.66";
    };
  };
}
