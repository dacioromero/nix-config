{...}: {
  imports = [./nerd-fonts.nix];

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      directory = {
        truncate_to_repo = true;
        truncation_symbol = "…/";
      };
      git_metrics.disabled = false;
      git_status.stashed = "";
      hostname = {
        format = "[$ssh_symbol$hostname]($style) ";
        ssh_only = false;
      };
    };
  };
}
