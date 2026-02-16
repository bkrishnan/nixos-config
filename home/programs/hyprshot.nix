{ ... }:

{
  programs.hyprshot = {
    enable = true;
    # Optional: Set save location (defaults to $XDG_PICTURES_DIR)
    saveLocation = "$HOME/Downloads";
  };
}
