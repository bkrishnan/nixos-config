{ pkgs, ... }:

{
  home.packages = with pkgs; [
    git
    vim
    emacs
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
  ];
}
