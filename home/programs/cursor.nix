{pkgs, ...}: {
  # ── Cursor theme: Bibata-Modern-Classic ───────────────────────────────────
  # Sets cursor for Wayland, XWayland, and GTK apps in one place.
  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
    gtk.enable = true; # writes gtk-3.0/gtk-4.0 settings
    x11.enable = true; # writes ~/.icons/default for XWayland apps
  };

  gtk = {
    enable = true;
    cursorTheme = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };
  };
}
