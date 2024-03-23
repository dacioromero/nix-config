{ pkgs, ... }: {
  services.gpg-agent.pinentryPackage = pkgs.pinentry-qt;
}
