# Mac Mini (Early 2009, MacMini3,1) — Hardware-specific configuration.
# Covers: boot loader, GPU driver, networking.hostId.
{...}: {
  # ── Boot ──────────────────────────────────────────────────────────────────
  # The Early 2009 Mac Mini supports EFI via Apple's firmware.
  # Use systemd-boot if the NixOS installer detects EFI, otherwise switch to GRUB.
  # Uncomment the appropriate block after running nixos-generate-config.

  # Option A — systemd-boot (EFI install):
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Option B — GRUB (legacy BIOS or EFI with GRUB):
  # boot.loader.grub.enable = true;
  # boot.loader.grub.device = "nodev";  # EFI
  # boot.loader.grub.efiSupport = true;
  # boot.loader.efi.canTouchEfiVariables = true;

  # ── GPU: NVIDIA GeForce 9400M (NV50/Tesla — Nouveau driver) ──────────────
  # The 9400M is supported by the open-source Nouveau driver.
  services.xserver.videoDrivers = ["nouveau"];

  # ── ZFS hostId ────────────────────────────────────────────────────────────
  # Required by ZFS to uniquely identify this host and prevent pool import
  # conflicts. Generate a unique value with:
  #   head -c4 /dev/urandom | od -A none -t x4
  # TODO: Replace this placeholder with a real generated value before first boot.
  networking.hostId = "00000000"; # REPLACE ME
}
