{ config, pkgs, ... }:

{
  imports = [
    ./home/programs/packages.nix
    ./home/programs/git.nix
    ./home/programs/fish.nix
    ./home/programs/starship.nix
    ./home/programs/vscode.nix
    ./home/programs/i3.nix
    ./home/programs/i3blocks.nix
    ./home/programs/foot.nix
    ./home/programs/hyprland.nix
    ./home/programs/hyprlock.nix
    ./home/programs/hypridle.nix
    ./home/programs/waybar.nix
    ./home/programs/direnv.nix
    ./home/programs/emacs.nix
    ./home/programs/swaync.nix
    ./home/programs/hyprshot.nix
    ./home/programs/satty.nix
  ];

  home.stateVersion = "25.11";
  
  home.username = "bkrishnan";
  home.homeDirectory = "/home/bkrishnan";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
