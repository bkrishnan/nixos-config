# ThinkPad T460 — Hardware-specific configuration.
# Covers: Intel HD Graphics 520 (i915), Intel wireless, ZFS hostId,
# Wayland session environment variables.
{pkgs, ...}: {
  # ── Boot ──────────────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Load i915 early for KMS (smooth boot, no flicker)
  boot.initrd.kernelModules = ["i915"];
  boot.kernelModules = ["kvm-intel"];

  # ── ZFS hostId (required by ZFS — must be unique per machine) ─────────────
  # Generated with: head -c4 /dev/urandom | od -A none -t x4
  networking.hostId = "b9bd5fcc";

  # ── GPU: Intel HD Graphics 520 (Skylake, Gen 9) ───────────────────────────
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Required for 32-bit apps (e.g. Steam)
    extraPackages = with pkgs; [
      intel-media-driver # VAAPI for Intel Gen 9+ (Skylake and newer)
      intel-vaapi-driver # Legacy VAAPI fallback
      libvdpau-va-gl # VDPAU → VA-API bridge for older apps
    ];
  };

  # ── Session Environment (Wayland / Hyprland) ──────────────────────────────
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD"; # Use intel-media-driver for Skylake

    # Wayland compatibility flags
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    SDL_VIDEODRIVER = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    CLUTTER_BACKEND = "wayland";
  };

  # ── System Packages (ThinkPad-specific tooling) ───────────────────────────
  environment.systemPackages = with pkgs; [
    pciutils # lspci — verify GPU/PCI layout
    mesa-demos # glxinfo — confirm active renderer
    libva-utils # vainfo — verify VA-API / Intel decode
    intel-gpu-tools # intel_gpu_top — Intel iGPU usage
  ];
}
