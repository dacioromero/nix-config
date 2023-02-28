{ pkgs
, inputs
, ...
}: {
  imports = with inputs.self.homeManagerModules; [
    home
    alacritty
  ];

  home.packages = with pkgs; [
    # colima
    # docker
    slack
    zoom-us
  ];

  # CCID is broken on MacOS
  # https://github.com/NixOS/nixpkgs/issues/155629
  programs.gpg.scdaemonSettings.disable-ccid = true;

  # Darwin doesn't support services.gpg-agent
  # https://github.com/nix-community/home-manager/issues/91
  home.file.".gnupg/gpg-agent.conf".text =
    let
      inherit (pkgs) pinentry_mac;
    in
    ''
      enable-ssh-support
      ttyname $GPG_TTY
      default-cache-ttl 60
      max-cache-ttl 120
      pinentry-program ${pinentry_mac}/${pinentry_mac.binaryPath}
    '';

  # launchd.agents.colima = {
  #   enable = true;
  #   config = {
  #     # colima start doesn't stay alive
  #     # https://gist.github.com/fardjad/a83c30b9b744b9612d793666f28361a5
  #     Program = toString (pkgs.writeShellScript "colima-start.sh" ''
  #       function shutdown() {
  #         ${pkgs.colima}/bin/colima stop
  #         exit 0
  #       }

  #       trap shutdown SIGTERM
  #       trap shutdown SIGKILL
  #       trap shutdown SIGINT

  #       ${pkgs.colima}/bin/colima start
  #       tail -f /dev/null &
  #       wait $!
  #     '');
  #     RunAtLoad = true;
  #     LaunchOnlyOnce = true;
  #     StandardOutPath = "${config.xdg.cacheHome}/colima.log";
  #     StandardErrorPath = "${config.xdg.cacheHome}/colima.log";
  #     # Give colima access to Docker
  #     EnvironmentVariables.PATH = "${pkgs.docker}/bin:/usr/bin:/bin:/usr/sbin:/sbin";
  #   };
  # };

  home.stateVersion = "22.05";
}
