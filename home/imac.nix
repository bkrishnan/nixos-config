# Home Manager — bkrishnan on the iMac.
# Imports common programs and adds the full Hyprland/Wayland + i3/X11 desktop stack.
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

    # X11 / i3 desktop
    ./programs/i3.nix
    ./programs/i3blocks.nix

    # Shared desktop utilities (used by both WMs)
    ./programs/foot.nix
    ./programs/rofi.nix
    ./programs/cursor.nix
  ];

  # iMac dual-monitor layout: 1440p right (primary) + 1080p left.
  # Overrides the generic ", preferred, auto, 1" fallback in programs/hyprland.nix.
  # The catch-all rule at the end handles any third display that might be connected.
  wayland.windowManager.hyprland.settings.monitor = lib.mkForce [
    "DP-1, 2560x1440, 1920x0, 1"
    "DP-2, 1920x1080, 0x180, 1"
    ", preferred, auto, 1"
  ];

  # iMac-specific xrandr layout: 1080p left monitor + 1440p primary right monitor.
  # Appended to the shared startup list defined in programs/i3.nix.
  xsession.windowManager.i3.config.startup = [
    {
      command = "xrandr --output DP-0 --off --output DP-1 --mode 1920x1080 --pos 0x180 --rotate normal --output DP-2 --primary --mode 2560x1440 --pos 1920x0 --rotate normal --output DP-3 --off --output DP-4 --off";
      always = true;
      notification = false;
    }
  ];
}
