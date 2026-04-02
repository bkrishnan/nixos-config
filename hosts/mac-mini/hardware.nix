# Mac Mini (Early 2009, MacMini3,1) — Hardware-specific configuration.
# Covers: boot loader, GPU driver, networking.hostId.
{
  config,
  lib,
  ...
}: {
  # ── Boot ──────────────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Broadcom BCM4321 Wi-Fi (requires proprietary broadcom-sta)
  boot.initrd.kernelModules = ["wl"];
  boot.kernelModules = ["wl"];
  boot.extraModulePackages = [config.boot.kernelPackages.broadcom_sta];

  # Blacklist conflicting open-source Wi-Fi drivers and proprietary NVIDIA
  boot.blacklistedKernelModules = [
    "b43"
    "bcma"
    "brcmsmac"
    "ssb" # Conflict with broadcom-sta
  ];


  # ── GPU: NVIDIA GeForce 9400M (NV50/Tesla — Nouveau driver) ──────────────
  # The 9400M is supported by the open-source Nouveau driver.
  services.xserver.videoDrivers = ["nouveau"];

  # ── ZFS hostId ────────────────────────────────────────────────────────────
  networking.hostId = "da5f4042";

  # ── Nixpkgs overrides (iMac-specific insecure allowance) ─────────────────
  # broadcom-sta is marked insecure; allow it by package name so the version
  # string doesn't need updating on each nixpkgs bump.
  nixpkgs.config.allowInsecurePredicate = pkg:
    builtins.elem (lib.getName pkg) ["broadcom-sta"];
}
