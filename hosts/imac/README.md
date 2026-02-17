# 🖥️ Host: iMac (Late 2012, 13,2)

Hostname: `imac` | Architecture: `x86_64-linux` | NixOS: `25.11`

## Hardware

| Component | Details |
|-----------|---------|
| CPU | Intel Core i7-3770S (Ivy Bridge) |
| GPU (primary) | NVIDIA GTX 680MX (NVE4 — Nouveau driver) |
| GPU (media) | Intel HD 4000 (i915 — VA-API decode) |
| Wi-Fi | Broadcom BCM4331 (broadcom-sta) |
| Display | 27-inch internal + optional external |
| Storage | Root on ext4; ZFS tools available |

## Hardware Configuration File

[`hardware.nix`](./hardware.nix) — imported automatically by `configuration.nix`.

Covers:
- **Boot**: systemd-boot, kernel parameters (`NvBoost=1` for stable Nouveau clocks)
- **Broadcom Wi-Fi**: `wl` kernel module + blacklist of conflicting open-source drivers
- **Dual-GPU load balancing**: Nouveau (desktop render) + Intel i915 (VA-API video decode)
- **ZFS**: filesystem support + TRIM
- **zram**: 60 % of RAM as compressed swap (zstd)
- **Session environment**: `AQ_DRM_DEVICES`, `LIBVA_DRIVER_NAME` for proper GPU routing

## The "Apple EFI iGPU" Problem

Apple's EFI firmware hides the Intel HD 4000 from non-macOS systems.

**Fix**: [rEFInd](https://www.rodsbooks.com/refind/) boot manager with `spoof_osx_version` set to a macOS version — this tricks the EFI into initialising both GPUs at POST.

## Why Nouveau Instead of Proprietary NVIDIA?

The proprietary NVIDIA 470 driver (the last to support this GPU on Linux) does not support GBM/Wayland. Nouveau (NVE4 backend) does, enabling a native Wayland session under Hyprland. The trade-off is slightly lower peak performance, mitigated by `NvBoost=1`.

## GPU Load Balancing

```
┌──────────────────────────────────┐
│  NVIDIA GTX 680MX (Nouveau/NVE4) │  ← Desktop renderer (Hyprland, UI)
│  /dev/dri/card1                  │
└──────────────┬───────────────────┘
               │ PCIe
┌──────────────┴───────────────────┐
│  Intel HD 4000 (i915)            │  ← Video decoder (VA-API for Chrome/VS Code)
│  /dev/dri/card0                  │
└──────────────────────────────────┘
```

Controlled via `AQ_DRM_DEVICES=/dev/dri/card0:/dev/dri/card1` and `LIBVA_DRIVER_NAME=i915`.

## Verification Commands

```bash
# Confirm active renderer is NVIDIA/Nouveau
glxinfo | grep "OpenGL renderer"

# Confirm Intel VA-API is working
vainfo

# Watch Intel GPU during video playback
sudo intel_gpu_top

# Watch NVIDIA GPU
nvtop
```

## Rebuild

```bash
sudo nixos-rebuild switch --flake .#imac
```
