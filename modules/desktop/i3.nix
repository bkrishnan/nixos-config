# i3 window manager — X11-based WM and its companion system packages.
# User-level i3 config (keybindings, bar, startup) lives in
# home/programs/i3.nix and home/programs/i3blocks.nix.
{pkgs, ...}: {
  services.xserver.enable = true;
  services.xserver.windowManager.i3 = {
    enable = true;
    package = pkgs.i3;
  };

  environment.systemPackages = with pkgs; [
    dmenu # Application launcher
    picom # Compositor for transparency and shadows
    xrandr # Screen resolution utility
    arandr # Graphical display configuration tool
    lxappearance # GTK theme switcher
  ];
}
