{ config, pkgs, ... }:

{
  home.stateVersion = "24.11";
  
  home.username = "bkrishnan";
  home.homeDirectory = "/home/bkrishnan";

  # User-specific packages
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
  ];

  # Git configuration
  programs.git = {
    enable = true;
    userName = "Bharath Krishnan";
    userEmail = "bkrishnan@gmail.com";
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
    };
  };

  # Fish shell configuration
  programs.fish = {
    enable = true;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
