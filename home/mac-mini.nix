# Home Manager — bkrishnan on the Mac Mini.
# Imports common programs and the i3/X11 desktop stack.
{...}: {
  imports = [
    ./common.nix

    # X11 / i3 desktop
    ./programs/i3.nix
    ./programs/i3blocks.nix

    # Desktop utilities
    ./programs/rofi.nix
    ./programs/cursor.nix
  ];
}
