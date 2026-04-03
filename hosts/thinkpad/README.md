# 💻 Host: ThinkPad T460

Hostname: `thinkpad` | Architecture: `x86_64-linux` | NixOS: `unstable`

## Hardware

| Component | Details |
|-----------|---------|
| CPU | Intel Core i7-6600U (Skylake, dual-core / 4 threads, 2.6–3.4 GHz) |
| GPU | Intel HD Graphics 520 (Skylake GT2, Gen 9) |
| Wi-Fi | Intel Wireless 8260 (iwlwifi — supported out of the box) |
| Display | 14-inch internal (eDP-1) |
| Storage | Root on ext4 |

## Hardware Configuration File

[`hardware.nix`](./hardware.nix) — imported automatically by `configuration.nix`.

Covers:
- **Boot**: systemd-boot, early i915 KMS modesetting
- **GPU**: Intel HD 520 with `intel-media-driver` (VAAPI Gen 9+)
- **ZFS hostId**: `b9bd5fcc` — required for ZFS support
- **Session environment**: `LIBVA_DRIVER_NAME=iHD`, Wayland compatibility flags

## ZFS

ZFS kernel support is enabled via `modules/services/zfs.nix`, but **no pools are auto-imported at boot**. This host is used with ad-hoc external drives — pool import and dataset mounting are done manually:

```bash
# Import a pool from an external drive (by ID to avoid device-path ambiguity)
sudo zpool import -d /dev/disk/by-id <pool-name>

# List imported pools and datasets
zpool list
zfs list

# Export the pool before unplugging the drive
sudo zpool export <pool-name>
```

> **Note**: Unlike the iMac, this host does NOT use `boot.zfs.extraPools` or `boot.zfs.requestEncryptionCredentials`. If you later add a permanent internal ZFS pool, set those in `hardware.nix` (see [iMac hardware.nix](../imac/hardware.nix) for reference).

## Desktop Environment

**Hyprland (Wayland only)** — no X11 or i3 on this host.

The built-in display (eDP-1) and any external monitors are auto-detected using the `", preferred, auto, 1"` fallback rule in `home/programs/hyprland.nix`. To add a fixed layout for a specific external monitor, override in `home/thinkpad.nix`:

```nix
# home/thinkpad.nix
wayland.windowManager.hyprland.settings.monitor = lib.mkForce [
  "HDMI-A-1, 1920x1080, 1366x0, 1"   # external monitor to the right
  ", preferred, auto, 1"               # catch-all (internal + anything else)
];
```

## First Boot — Before Running nixos-rebuild

1. **Replace `hardware-configuration.nix`** with the file generated on the ThinkPad:
   ```bash
   sudo nixos-generate-config --show-hardware-config > hosts/thinkpad/hardware-configuration.nix
   ```
   Or copy `/etc/nixos/hardware-configuration.nix` directly from the machine.

2. **Commit the file** and push to the repo (or copy to the ThinkPad).

3. **Switch**:
   ```bash
   sudo nixos-rebuild switch --flake .#thinkpad
   ```

## Rebuild

```bash
sudo nixos-rebuild switch --flake .#thinkpad
```
