{ pkgs, ... }: {
  imports = [ ./starship ];

  home.packages = with pkgs; [
    nil
    thefuck
  ];

  home.sessionVariables = {
    EDITOR = "code --wait";
    # thefuck has a bad suggestion
    # https://github.com/nvbn/thefuck/issues/1153
    THEFUCK_EXCLUDE_RULES = "fix_file";
    # direnv is noisy especially w/ nix-direnv
    # https://github.com/direnv/direnv/issues/68
    DIRENV_LOG_FORMAT = "";
  };

  home.sessionPath = [ "$HOME/.local/bin" ];

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "yarn" "thefuck" ];
      # https://github.com/zsh-users/zsh-syntax-highlighting/issues/295#issuecomment-214581607
      extraConfig = ''
        zstyle ':bracketed-paste-magic' active-widgets '.self-*'
      '';
    };
    # plugins = [{
    #   name= "fast-syntax-highlighting";
    #   src = "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions";
    #   file = "fast-syntax-highlighting.plugin.zsh";
    # }];
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };

  programs.git = {
    enable = true;
    userName = "Dacio Romero";
    userEmail = "dacioromero@gmail.com";
    signing = {
      key = "0x8A876FD29358A925";
      signByDefault = true;
    };
    aliases = {
      root = "rev-parse --show-toplevel";
      ignore = "!gi() { curl -sL https://www.toptal.com/developers/gitignore/api/$@ ;}; gi";
    };
    extraConfig = {
      init.defaultBranch = "main";
      merge.ff = false;
      pull.ff = "only";
      advice.detatchedHead = false;
      # Git has poor performance in mono repos which affects Starship
      # https://github.com/starship/starship/issues/4305#issuecomment-1222882244
      feature.manyFiles = true;
      url."git@github.com:".pushInsteadOf = "https://github.com/";
      url."git@gitlab.com:".pushInsteadOf = "https://gitlab.com/";
    };
  };

  programs.gpg = {
    enable = true;
    # Missing config to match
    # https://github.com/drduh/config/blob/725d5cea5170d8bec514f5c41f08afe1f143ab1b/gpg.conf#L43-L44
    settings.throw-keyids = true;
    publicKeys = [
      {
        source = ../../keys/gpg.asc;
        trust = "ultimate";
      }
    ];
  };

  programs.tmux.enable = true;

  programs.lf = {
    enable = true;
    keybindings."<delete>" = "delete";
  };

  programs.htop.enable = true;
  programs.htop.settings = {
    show_program_path = 0;
    hide_userland_threads = 1;
  };

  programs.home-manager.enable = true;
}
