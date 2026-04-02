# Hyprland (Wayland) — system-level enablement and Wayland-native packages.
# User-level Hyprland config (keybindings, animations, monitors) lives in
# home/programs/hyprland.nix.
{pkgs, ...}: {
  programs.hyprland.enable = true;

  environment.systemPackages = with pkgs; [
    rofi # App launcher
    waybar # Status bar
  ];
}
