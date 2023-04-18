{
  programs.wezterm = {
    enable = true;
    colorSchemes.Omni = {
      ansi = [
        "#000000"
        "#FF5555"
        "#50FA7B"
        "#EFFA78"
        "#BD93F9"
        "#FF79C6"
        "#8D79BA"
        "#BFBFBF"
      ];
      brights = [
        "#4D4D4D"
        "#FF6E67"
        "#5AF78E"
        "#EAF08D"
        "#CAA9FA"
        "#FF92D0"
        "#AA91E3"
        "#E6E6E6"
      ];
      background = "#191622";
      cursor_bg = "#F8F8F2";
      cursor_fg = "#191622";
      foreground = "#E1E1E6";
      selection_bg = "#41414D";
      selection_fg = "#E1E1E6";
    };
    extraConfig = ''
      return {
        color_scheme = "Omni",
        font = wezterm.font 'JetBrains Mono',
        window_background_opacity = 0.95,
        enable_scroll_bar = true,
      }
    '';
  };
}
