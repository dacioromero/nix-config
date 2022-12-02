{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  # https://github.com/simonvpe/simux/blob/c6e303f752d27965c58addb8398249a58e08b9d7/users/profiles/terminal/default.nix#L11-L17
  fromYAML = yaml:
    builtins.fromJSON (
      builtins.readFile (
        pkgs.runCommand "from-yaml"
        {}
        ''
          cat <<EOF | ${pkgs.yq}/bin/yq '.' > $out
          ${yaml}
          EOF
        ''
      )
    );
in {
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
    settings =
      {
        font =
          lib.genAttrs [
            "normal"
            "bold"
            "italic"
            "bold_italic"
          ] (_: {
            family = "JetBrainsMono Nerd Font";
          })
          // {
            size = 14;
          };
        window = {
          padding.x = 8;
          padding.y = 8;
        };
      }
      // fromYAML (builtins.readFile "${inputs.omni-alacritty}/omni.yml");
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
