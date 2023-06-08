{
  home.packages = with pkgs; [
    obsidian
    vscode
  ];

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    defaultCacheTtl = 60;
    maxCacheTtl = 120;
  };
}
