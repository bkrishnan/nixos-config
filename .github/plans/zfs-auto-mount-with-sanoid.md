# Plan: ZFS Encrypted Mount + Sanoid Setup

**TL;DR**: Three files change — ZFS boot options in `hosts/imac/hardware.nix`, sanoid service + timer in `configuration.nix`, and documentation updates in `Readme.md` and `hosts/imac/README.md`.

---

## Phase 1 — ZFS Encrypted Mount (hosts/imac/hardware.nix)

1. Add `boot.zfs.extraPools = ["rpool"]` — rpool is not the root pool (root is ext4), so NixOS won't import it automatically otherwise
2. Add `boot.zfs.requestEncryptionCredentials = [ "rpool/data" ]` — **list form**, not `true`. This prompts for the passphrase only for `rpool/data`. All its children inherit the key and get mounted by `zfs-mount.service` using their ZFS `mountpoint` properties. Other encrypted datasets in `rpool` with separate keys receive **no key** and won't mount.

   > **Important caveat on other rpool datasets**: If other datasets in `rpool` are unencrypted (or share `rpool/data`'s key), they will still mount based on their ZFS `canmount` property. To prevent that, run `zfs set canmount=noauto <dataset>` on each one — this is a one-time manual step outside Nix, since Nix doesn't control existing ZFS properties. This will be documented.

---

## Phase 2 — Sanoid NixOS Module (configuration.nix)

3. Add `lib` to module args: `{lib, pkgs, ...}:` (currently `{pkgs, ...}:`)
4. Add `services.sanoid` block:
   - **Active dataset**: `datasets."rpool/data"` → `use_template = ["production"]`, `recursive = true`, `process_children_only = true`
   - **All 6 templates** from the reference conf:
     - `production` — standard counts + `autosnap`/`autoprune` (fully typed in the module)
     - `demo` — just `daily = 60`
     - `backup` — standard counts + monitoring thresholds (`hourly_warn = 2880`, `daily_warn = 48`, etc.)
     - `hotspare` — standard counts + time-suffixed thresholds (`hourly_warn = "4h"`, `daily_warn = "2d"`, etc.)
     - `scripts` — script hook paths + `script_timeout` (no dataset uses this; kept as reference)
     - `ignore` — `autoprune = false`, `autosnap = false`, `monitor = false`
   - Monitoring thresholds and script hook options are not in the NixOS module's typed schema → those templates go into `services.sanoid.extraConfig` as a raw INI string

5. Add timer override:
   ```
   systemd.timers.sanoid.timerConfig.OnCalendar = lib.mkForce "*:0/15"
   systemd.timers.sanoid.timerConfig.Persistent = lib.mkForce true
   ```
   (`lib.mkForce` needed to override the default set by the sanoid module)

---

## Phase 3 — Documentation Updates

6. `Readme.md`:
   - Hosts table: Update imac Storage entry to reflect encrypted ZFS `rpool/data` auto-mount
   - Core Tools section: Add Sanoid as snapshot management tool

7. `hosts/imac/README.md`:
   - Hardware table: Update Storage row
   - Add new **"ZFS Data Pool"** section documenting: boot passphrase prompt, what mounts, the `canmount=noauto` caveat for other rpool datasets, and the sanoid snapshot schedule
   - Verification Commands: Add `zfs list -r rpool/data` and sanoid-related commands

---

## Relevant Files

- `hosts/imac/hardware.nix` — add `boot.zfs.extraPools` + `boot.zfs.requestEncryptionCredentials`
- `configuration.nix` — add `lib` to args, `services.sanoid` block, `systemd.timers.sanoid` override
- `Readme.md` — update hosts table + core tools
- `hosts/imac/README.md` — update hardware table + add ZFS section

## Verification

1. `sudo nixos-rebuild build --flake .#imac` — dry build first
2. `sudo nixos-rebuild switch --flake .#imac`
3. Reboot — passphrase prompt should appear before Ly
4. `zfs list -r rpool/data` — verify dataset + children mounted
5. `zfs list rpool/<other>` — spot-check that other datasets did NOT mount (or apply `canmount=noauto` as needed)
6. `systemctl status sanoid.timer` — confirm 15-minute interval
7. `sudo sanoid --cron --verbose` — manual run to verify snapshot policy applies
8. `zfs list -t snapshot -r rpool/data` — confirm snapshots were created

## Decisions

- `requestEncryptionCredentials` as a list `["rpool/data"]` (not `true`) — scoped to data only
- Templates `backup`, `hotspare`, `scripts` use `extraConfig` for non-standard INI fields
- `.config/sanoid.conf` stays in the repo as a git-ignored reference file — Nix owns the generated config at `/etc/sanoid/sanoid.conf`
- Both README files updated per your request

## Post install/switch commands

### Suppress auto-mount of all non-data datasets that currently have canmount=on
```
sudo zfs set canmount=noauto rpool/home
sudo zfs set canmount=noauto rpool/home/root
sudo zfs set canmount=noauto rpool/opt
sudo zfs set canmount=noauto rpool/tmp
sudo zfs set canmount=noauto rpool/var/cache
sudo zfs set canmount=noauto rpool/var/lib/AccountsService
sudo zfs set canmount=noauto rpool/var/lib/docker
sudo zfs set canmount=noauto rpool/var/log
sudo zfs set canmount=noauto rpool/var/spool
sudo zfs set canmount=noauto rpool/var/tmp
```

### Pre-existing settings for reference

```
zfs list -r rpool -o name,encryption,keystatus,keylocation,encryptionroot,canmount
NAME                           ENCRYPTION   KEYSTATUS    KEYLOCATION  ENCROOT  CANMOUNT
rpool                          aes-256-gcm  unavailable  prompt       rpool    off
rpool/ROOT                     aes-256-gcm  unavailable  none         rpool    off
rpool/ROOT/arch                aes-256-gcm  unavailable  none         rpool    noauto
rpool/data                     aes-256-gcm  unavailable  none         rpool    off
rpool/data/bin                 aes-256-gcm  unavailable  none         rpool    on
rpool/data/code                aes-256-gcm  unavailable  none         rpool    on
rpool/data/documents           aes-256-gcm  unavailable  none         rpool    on
rpool/data/notes               aes-256-gcm  unavailable  none         rpool    on
rpool/data/photos              aes-256-gcm  unavailable  none         rpool    on
rpool/data/photos/exports      aes-256-gcm  unavailable  none         rpool    on
rpool/data/voice               aes-256-gcm  unavailable  none         rpool    on
rpool/home                     aes-256-gcm  unavailable  none         rpool    on
rpool/home/root                aes-256-gcm  unavailable  none         rpool    on
rpool/media                    aes-256-gcm  unavailable  none         rpool    off
rpool/opt                      aes-256-gcm  unavailable  none         rpool    on
rpool/tmp                      aes-256-gcm  unavailable  none         rpool    on
rpool/var                      aes-256-gcm  unavailable  none         rpool    off
rpool/var/cache                aes-256-gcm  unavailable  none         rpool    on
rpool/var/lib                  aes-256-gcm  unavailable  none         rpool    off
rpool/var/lib/AccountsService  aes-256-gcm  unavailable  none         rpool    on
rpool/var/lib/docker           aes-256-gcm  unavailable  none         rpool    on
rpool/var/log                  aes-256-gcm  unavailable  none         rpool    on
rpool/var/spool                aes-256-gcm  unavailable  none         rpool    on
rpool/var/tmp                  aes-256-gcm  unavailable  none         rpool    on
```