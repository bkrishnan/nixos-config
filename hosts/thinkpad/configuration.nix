# ThinkPad T460 — System configuration.
# Hyprland-only Wayland desktop. ZFS enabled for ad-hoc external drives
# (no pools are auto-imported at boot — mount manually with zpool import).
{pkgs, ...}: {
  imports = [
    # Auto-generated hardware scan — copy from /etc/nixos/hardware-configuration.nix
    # on the ThinkPad and commit it here before rebuilding.
    ./hardware-configuration.nix

    # ThinkPad-specific: Intel GPU, ZFS hostId, Wayland session env
    ./hardware.nix

    # Shared base config (locale, fonts, users, shell, nix settings)
    ../../modules/common.nix

    # Desktop environment — Hyprland only (no X11/i3 on this host)
    ../../modules/desktop/hyprland.nix

    # System services
    ../../modules/services/openssh.nix
    ../../modules/services/tailscale.nix
    ../../modules/services/avahi.nix # mDNS — required for printer/scanner .local resolution
    ../../modules/services/zfs.nix # ZFS tools + kernel support (no pools auto-imported)

    # Peripheral devices
    ../../modules/devices/brother-printer.nix
    ../../modules/devices/brother-scanner.nix
  ];

  networking.hostName = "thinkpad";

  # Ly TUI display manager — Wayland sessions only on this host.
  services.displayManager.ly = {
    enable = true;
    settings = {
      wayland_spec = "/run/current-system/sw/share/wayland-sessions";
    };
  };

  # Terminal emulators available system-wide.
  environment.systemPackages = with pkgs; [
    alacritty
    foot # Wayland-native terminal
  ];
}
