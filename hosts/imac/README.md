# 🖥️ Host: iMac (Late 2012, 13,2)

Hostname: `imac` | Architecture: `x86_64-linux` | NixOS: `unstable`

## Hardware

| Component | Details |
|-----------|---------|
| CPU | Intel Core i7-3770S (Ivy Bridge) |
| GPU (primary) | NVIDIA GTX 680MX (NVE4 — Nouveau driver) |
| GPU (media) | Intel HD 4000 (i915 — VA-API decode) |
| Wi-Fi | Broadcom BCM4331 (broadcom-sta) |
| Display | 27-inch internal + optional external |
| Storage | Root on ext4; `rpool/data` (native ZFS encryption) auto-mounted at boot with passphrase prompt |

## Hardware Configuration File

[`hardware.nix`](./hardware.nix) — imported automatically by `configuration.nix`.

Covers:
- **Boot**: systemd-boot, kernel parameters (`NvBoost=1` for stable Nouveau clocks)
- **Broadcom Wi-Fi**: `wl` kernel module + blacklist of conflicting open-source drivers
- **Dual-GPU load balancing**: Nouveau (display output) + Intel i915 (Hyprland renderer + VA-API video decode)
- **ZFS**: filesystem support + TRIM
- **Session environment**: `AQ_DRM_DEVICES`, `LIBVA_DRIVER_NAME` for proper GPU routing

For full GPU details, driver rationale, and Hyprland rendering behaviour, see [nvidia.md](./nvidia.md).

## ZFS Data Pool

`rpool/data` uses native ZFS encryption. During boot — before Ly starts — the system prompts for the passphrase in the initrd stage. After the key is loaded, `zfs-mount.service` mounts `rpool/data` and all child datasets using their ZFS `mountpoint` properties.

**What mounts at boot:**
- `rpool/data` and all children that inherit its encryption key
- Children must have `canmount=on` (the default)

**What does NOT mount:**
- Other datasets in `rpool` encrypted with separate keys (no key is loaded for them)
- Any dataset where `canmount=noauto` or `canmount=off` is set

> **Preventing unwanted mounts**: If `rpool` contains unencrypted datasets (or datasets sharing `rpool/data`'s key) that should not auto-mount, run once per dataset:
> ```bash
> zfs set canmount=noauto <dataset>
> ```
> This is a one-time manual step — NixOS does not control existing ZFS dataset properties.

**Sanoid snapshots** are managed declaratively in `modules/services/sanoid.nix` via `services.sanoid`. The timer fires every 15 minutes; the production template retains 36 hourlies, 30 dailies, and 3 monthlies.

## Verification Commands

```bash
# Verify rpool/data and children are mounted
zfs list -r rpool/data

# Check that the passphrase was loaded at boot
zfs get keystatus rpool/data

# Confirm sanoid timer is active and running every 15 min
systemctl status sanoid.timer

# Run sanoid manually to verify snapshot policy
sudo sanoid --cron --verbose

# List snapshots taken by sanoid
zfs list -t snapshot -r rpool/data
```

## Rebuild

```bash
sudo nixos-rebuild switch --flake .#imac
```
