# 🖥️ Host: Mac Mini (Early 2009, MacMini3,1)

Hostname: `mac-mini` | Architecture: `x86_64-linux` | NixOS: `unstable`

## Hardware

| Component | Details |
|-----------|---------|
| CPU | Intel Core 2 Duo (Penryn) |
| GPU | NVIDIA GeForce 9400M (NV50/Tesla — Nouveau driver) |
| Wi-Fi | Apple Airport Extreme (Broadcom) |
| Storage | Root on ext4 |
| Display | External monitor via Mini-DVI or DisplayPort |

## Hardware Configuration File

[`hardware.nix`](./hardware.nix) — imported automatically by `configuration.nix`.

Covers:
- **Boot**: systemd-boot (EFI) or GRUB — confirm after installation
- **GPU**: Nouveau driver for NVIDIA GeForce 9400M
- **ZFS hostId**: must be set to a unique value before first boot

## Before First Boot Checklist

1. **Generate a real `networking.hostId`** in `hardware.nix`:
   ```bash
   head -c4 /dev/urandom | od -A none -t x4
   ```
   Replace `"00000000"` with the generated value.

2. **Replace `hardware-configuration.nix`** with the output of `nixos-generate-config`:
   ```bash
   nixos-generate-config --root /mnt
   cp /mnt/etc/nixos/hardware-configuration.nix hosts/mac-mini/hardware-configuration.nix
   ```

3. **Confirm boot loader**: Check whether the installer booted in EFI or BIOS mode and update `hardware.nix` accordingly.

## Bootstrapping Flakes on a Fresh NixOS Install

A stock NixOS installation does not have flakes enabled, so `nixos-rebuild --flake` won't work out of the box. You need to enable flakes first using the default imperative config, then switch to this repo.

**Step 1 — Enable flakes in the installer config.**
Edit `/etc/nixos/configuration.nix` (the one the installer generated) and add:
```nix
nix.settings.experimental-features = ["nix-command" "flakes"];
```
Then apply it:
```bash
sudo nixos-rebuild switch
```

**Step 2 — Clone this repo.**
```bash
sudo nixos-install --no-root-passwd  # skip if already installed
git clone <repo-url> ~/nixos-config
cd ~/nixos-config
```

**Step 3 — Switch to the flake config.**
```bash
sudo nixos-rebuild switch --flake ~/nixos-config#mac-mini
```

After this first switch, the flake's `modules/common.nix` takes over managing `nix.settings.experimental-features`, so the installer config is no longer used.

## Desktop Environment

This host uses **XFCE** as the desktop environment with the **Ly** display manager.

## ZFS

This host does **not** use ZFS. Root filesystem is ext4. The `modules/services/zfs.nix` module is not imported.

## Peripheral Devices

Both the Brother HL-L2300D printer and Brother MFC-J410W scanner are configured (same as the `imac` host). See `modules/devices/` for configuration and documentation.
