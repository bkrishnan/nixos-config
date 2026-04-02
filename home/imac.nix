# Home Manager — bkrishnan on the iMac.
# Imports common programs and adds the full Hyprland/Wayland + i3/X11 desktop stack.
{...}: {
  imports = [
    ./common.nix

    # Wayland / Hyprland desktop
    ./programs/hyprland.nix
    ./programs/hyprlock.nix
    ./programs/hypridle.nix
    ./programs/hyprshot.nix
    ./programs/waybar.nix
    ./programs/swaync.nix
    ./programs/satty.nix

    # X11 / i3 desktop
    ./programs/i3.nix
    ./programs/i3blocks.nix

    # Shared desktop utilities (used by both WMs)
    ./programs/foot.nix
    ./programs/rofi.nix
    ./programs/cursor.nix
  ];
}
