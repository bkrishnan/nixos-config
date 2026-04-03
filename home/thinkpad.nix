# Home Manager — bkrishnan on the ThinkPad T460.
# Imports common programs and the full Hyprland/Wayland desktop stack.
# No X11/i3 — Hyprland is the only DE on this host.
{lib, ...}: {
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

    # Shared desktop utilities
    ./programs/foot.nix
    ./programs/rofi.nix
    ./programs/cursor.nix
  ];

  # ThinkPad has a single built-in display (eDP-1).
  # The generic ", preferred, auto, 1" rule in programs/hyprland.nix handles it.
  # External monitors connected via HDMI/DP are also auto-detected by that rule.
  # Override here only if you need a fixed resolution or multi-monitor layout.

  # Intel HD 520 handles hardware cursors fine — no need to override
  # no_hardware_cursors (it is set to true in hyprland.nix for Nouveau compat
  # and is harmless on Intel).
  wayland.windowManager.hyprland.settings.cursor = lib.mkForce {
    no_hardware_cursors = false;
  };
}
