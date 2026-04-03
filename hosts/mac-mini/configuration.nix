# Mac Mini (Early 2009) — System configuration.
# Composes shared modules for XFCE, core services, and devices
# that are present on this machine.
{pkgs, ...}: {
  imports = [
    # Auto-generated hardware scan — do not edit
    # Replace with the actual output of `nixos-generate-config --root /mnt`
    ./hardware-configuration.nix

    # Mac Mini-specific: boot loader, GPU driver, networking.hostId
    ./hardware.nix

    # Shared base config (locale, fonts, users, shell, nix settings)
    ../../modules/common.nix

    # Desktop environment
    ../../modules/desktop/xfce.nix

    # System services
    ../../modules/services/openssh.nix
    ../../modules/services/tailscale.nix
    ../../modules/services/avahi.nix # mDNS — required for printer/scanner .local resolution

    # Peripheral devices
    ../../modules/devices/brother-printer.nix
    ../../modules/devices/brother-scanner.nix
  ];

  networking.hostName = "mac-mini";

  # Ly TUI display manager — point it at the X11 session files XFCE installs.
  services.displayManager.ly.enable = true;

  environment.systemPackages = with pkgs; [
    alacritty
    pciutils # lspci — verify GPU/PCI layout
    mesa-demos # glxinfo — confirm active renderer
  ];
}
