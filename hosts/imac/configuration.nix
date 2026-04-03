# iMac (Late 2012, 13,2) — System configuration.
# Composes shared modules for desktop environments, services, and devices
# that are present on this machine.
{pkgs, ...}: {
  imports = [
    # Auto-generated hardware scan — do not edit
    ./hardware-configuration.nix

    # iMac-specific: GPU drivers, Broadcom Wi-Fi, ZFS hostId, kernel params
    ./hardware.nix

    # Shared base config (locale, fonts, users, shell, nix settings)
    ../../modules/common.nix

    # Desktop environments
    ../../modules/desktop/hyprland.nix # Wayland compositor
    ../../modules/desktop/i3.nix # X11 window manager
    ../../modules/desktop/gnome.nix # GNOME (for GDM/GNOME apps)

    # System services
    ../../modules/services/openssh.nix
    ../../modules/services/tailscale.nix
    ../../modules/services/avahi.nix # mDNS — required for printer/scanner .local resolution
    ../../modules/services/zfs.nix # ZFS support (hostId set in hardware.nix)
    ../../modules/services/sanoid.nix # Automated ZFS snapshots

    # Peripheral devices
    ../../modules/devices/brother-printer.nix
    ../../modules/devices/brother-scanner.nix
  ];

  networking.hostName = "imac";

  # Ly TUI display manager — presents both Wayland and X11 session choices.
  services.displayManager.ly = {
    enable = true;
    settings = {
      # Direct Ly to the NixOS-generated Wayland session path
      wayland_spec = "/run/current-system/sw/share/wayland-sessions";
      # Also include X11 sessions for i3
      x_spec = "/run/current-system/sw/share/xsessions";
    };
  };
  services.displayManager.gdm.wayland = false;

  # Terminal emulators available system-wide (used by both Hyprland and i3).
  environment.systemPackages = with pkgs; [
    alacritty
    foot # Wayland-native terminal
  ];
}
