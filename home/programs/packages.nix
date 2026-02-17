{pkgs, ...}: {
  home.packages = with pkgs; [
    git
    vim
    fish
    curl
    wget
    htop
    tree
    google-chrome
    vscode
    # i3 dependencies
    dex
    xss-lock
    i3lock
    networkmanagerapplet
    pavucontrol
    feh
    nitrogen
    zenity
    swaynotificationcenter
    libnotify
    satty
    libreoffice
    fastfetch
    simple-scan
    # Nix tooling
    alejandra
  ];
}
