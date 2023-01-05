{
  imports = [./nerd-fonts.nix];

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      command_timeout = 250;
      directory = {
        truncate_to_repo = true;
        truncation_symbol = "…/";
      };
      git_branch.truncation_length = 24;
      git_metrics.disabled = false;
      git_status.stashed = "";
      hostname = {
        format = "[$ssh_symbol$hostname]($style) ";
        ssh_only = false;
      };
      nix_shell.disabled = true;
      dotnet.detect_files = ["global.json" "Directory.Build.props" "Directory.Build.targets" "Packages.props"]; # Excluding project.json
      java.detect_extensions = ["java" "class" "gradle" "cljs" "cljc"]; # Exluding .jar
    };
  };
}
