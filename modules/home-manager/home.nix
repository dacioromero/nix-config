{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [./starship];
  home.packages = with pkgs; [thefuck obsidian vscode slack zoom-us];

  home.sessionVariables = {
    EDITOR = "code --wait";
    # thefuck has a bad suggestion
    # https://github.com/nvbn/thefuck/issues/1153
    THEFUCK_EXCLUDE_RULES = "fix_file";
    # direnv is noisy especially w/ nix-direnv
    # https://github.com/direnv/direnv/issues/68
    DIRENV_LOG_FORMAT = "";
  };

  home.sessionPath = ["$HOME/.local/bin"];

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
    oh-my-zsh = {
      enable = true;
      plugins = ["git" "yarn" "thefuck"];
      # https://github.com/zsh-users/zsh-syntax-highlighting/issues/295#issuecomment-214581607
      extraConfig = ''
        zstyle ':bracketed-paste-magic' active-widgets '.self-*'
      '';
    };
    # plugins = [{
    #   name= "fast-syntax-highlighting";
    #   src = "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions";
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
    };
  };

  programs.gpg = {
    enable = true;
    # Missing config to match
    # https://github.com/drduh/config/blob/725d5cea5170d8bec514f5c41f08afe1f143ab1b/gpg.conf#L43-L44
    settings.throw-keyids = true;
    publicKeys = [
      {
        source = builtins.fetchurl {
          url = "https://keybase.io/dacio/pgp_keys.asc";
          sha256 = "12n9iva8jj7r9d96wb77rp56c6w2dc5jqsbwsxbnc64k6b6knxac";
        };
        trust = "ultimate";
      }
    ];
  };

  programs.alacritty = {
    enable = true;
    settings = {
      import = ["${inputs.omni-alacritty}/omni.yml"];
      font = let
        mkFace = style: {
          family = "JetBrainsMono Nerd Font";
          inherit style;
        };
      in {
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
    };
  };

  programs.tmux.enable = true;

  home.stateVersion = "22.05";

  programs.home-manager.enable = true;
}
