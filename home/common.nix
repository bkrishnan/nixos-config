# Home Manager — programs common to bkrishnan on every host.
# Per-host home files (home/imac.nix, home/mac-mini.nix) import this and
# add host-specific program modules on top.
{...}: {
  imports = [
    ./programs/packages.nix
    ./programs/git.nix
    ./programs/fish.nix
    ./programs/starship.nix
    ./programs/direnv.nix
    ./programs/emacs.nix
    ./programs/vscode.nix
  ];

  home.stateVersion = "25.11";
  home.username = "bkrishnan";
  home.homeDirectory = "/home/bkrishnan";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
