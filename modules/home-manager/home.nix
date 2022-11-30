{
  config,
  pkgs,
  lib,
  ...
}: {
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [thefuck obsidian vscode slack];

  home.sessionVariables = {
    EDITOR = "code --wait";
    # https://github.com/nvbn/thefuck/issues/1153
    THEFUCK_EXCLUDE_RULES = "fix_file";
  };

  home.sessionPath = ["$HOME/.local/bin"];

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
    oh-my-zsh = {
      enable = true;
      plugins = ["git" "yarn" "thefuck"];
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };

  programs.starship.enable = true;
  xdg.configFile."starship.toml".source = ./starship.toml;

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
      advice.detatchedHead = false;
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

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}