{ config, pkgs, ... }:

{
  imports = [
    ./home/programs/packages.nix
    ./home/programs/git.nix
    ./home/programs/fish.nix
    ./home/programs/vscode.nix
    ./home/programs/i3.nix
    ./home/programs/i3blocks.nix
    ./home/programs/foot.nix
  ];

  home.stateVersion = "25.11";
  
  home.username = "bkrishnan";
  home.homeDirectory = "/home/bkrishnan";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
