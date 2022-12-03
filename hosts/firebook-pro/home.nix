{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    ../../modules/home-manager/home.nix
  ];

  home.username = "dacio";
  home.homeDirectory = "/Users/dacio";

  home.packages = with pkgs; [
    colima
    docker
  ];

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
        size = 14;
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

  # CCID is broken on MacOS
  # https://github.com/NixOS/nixpkgs/issues/155629
  programs.gpg.scdaemonSettings.disable-ccid = true;

  # Darwin doesn't support services.gpg-agent
  # https://github.com/nix-community/home-manager/issues/91
  home.file.".gnupg/gpg-agent.conf".text = let
    inherit (pkgs) pinentry_mac;
  in ''
    enable-ssh-support
    ttyname $GPG_TTY
    default-cache-ttl 60
    max-cache-ttl 120
    pinentry-program ${pinentry_mac}/${pinentry_mac.binaryPath}
  '';

  launchd.agents.colima = {
    enable = true;
    config = {
      # colima start doesn't stay alive
      # https://gist.github.com/fardjad/a83c30b9b744b9612d793666f28361a5
      Program = toString (pkgs.writeShellScript "colima-start.sh" ''
        function shutdown() {
          ${pkgs.colima}/bin/colima stop
          exit 0
        }

        trap shutdown SIGTERM
        trap shutdown SIGKILL
        trap shutdown SIGINT

        ${pkgs.colima}/bin/colima start
        tail -f /dev/null &
        wait $!
      '');
      RunAtLoad = true;
      LaunchOnlyOnce = true;
      StandardOutPath = "${config.xdg.cacheHome}/colima.log";
      StandardErrorPath = "${config.xdg.cacheHome}/colima.log";
      EnvironmentVariables = {
        # Give colima access to Docker
        PATH = "${pkgs.docker}/bin:/usr/bin:/bin:/usr/sbin:/sbin";
      };
    };
  };
}
