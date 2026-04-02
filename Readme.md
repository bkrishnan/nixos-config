
# 🗂️ NixOS Configuration

A modular, flake-based NixOS monorepo using **Home Manager** (integrated as a NixOS module). Each host picks the modules it needs — shared base config, optional desktop environments, services, and devices — from a central `modules/` tree. Home Manager is split into common programs and per-host profiles.

## Repository Structure

```
.
├── flake.nix                        # Entry point — one nixosConfigurations entry per host
│
├── modules/                         # Reusable NixOS modules — imported per-host as needed
│   ├── common.nix                   # Shared base: locale, fonts, users, shell, nix settings
│   ├── desktop/
│   │   ├── hyprland.nix             # Wayland compositor (system-level enable + packages)
│   │   ├── i3.nix                   # X11 window manager + companion packages
│   │   ├── gnome.nix                # GNOME desktop manager
│   │   └── xfce.nix                 # XFCE desktop environment
│   ├── services/
│   │   ├── openssh.nix              # SSH server (pubkey-only)
│   │   ├── tailscale.nix            # Tailscale VPN
│   │   ├── avahi.nix                # mDNS / .local resolution (required for printer)
│   │   ├── zfs.nix                  # ZFS support + zram swap
│   │   └── sanoid.nix               # Automated ZFS snapshot management
│   └── devices/
│       ├── brother-printer.nix      # Brother HL-L2300D (IPP network printer)
│       ├── brother-printer.md
│       ├── brother-scanner.nix      # Brother MFC-J410W (brscan4 network scanner)
│       └── brother-scanner.md
│
├── hosts/                           # Per-host entry points
│   ├── imac/
│   │   ├── configuration.nix        # Imports modules + sets hostname, display manager
│   │   ├── hardware-configuration.nix  # Auto-generated — do not edit
│   │   ├── hardware.nix             # iMac GPU, Wi-Fi, ZFS hostId, kernel params
│   │   └── README.md
│   └── mac-mini/
│       ├── configuration.nix        # Imports modules + sets hostname, display manager
│       ├── hardware-configuration.nix  # Replace with nixos-generate-config output
│       ├── hardware.nix             # Mac Mini boot loader, GPU, networking.hostId
│       └── README.md
│
├── home/                            # Home Manager profiles for user bkrishnan
│   ├── common.nix                   # Programs on every host: git, fish, emacs, vscode, …
│   ├── imac.nix                     # iMac: adds Hyprland/Wayland + i3/X11 desktop stack
│   ├── mac-mini.nix                 # Mac Mini: common only (XFCE is system-level)
│   └── programs/                   # Modular per-program HM declarations
│       ├── packages.nix
│       ├── fish.nix
│       ├── git.nix
│       ├── emacs.nix
│       ├── vscode.nix
│       ├── hyprland.nix
│       ├── i3.nix
│       └── …
│
└── config/                          # Raw config files (non-Nix) sourced by Home Manager
    ├── emacs/init.el
    └── rofi/rounded-nord-dark.rasi
```

## Design Principles

### Module System — Import Lists

Each host's `configuration.nix` explicitly imports the modules it needs from `modules/`. There are no enable flags — if a module isn't imported, it's not active. This keeps each host's composition readable at a glance.

```
hosts/imac/configuration.nix
  └── modules/common.nix           # base: users, fonts, locale, shell
  └── modules/desktop/hyprland.nix # Wayland WM
  └── modules/desktop/i3.nix       # X11 WM
  └── modules/desktop/gnome.nix    # GNOME
  └── modules/services/zfs.nix     # ZFS + zram (iMac only)
  └── modules/services/sanoid.nix  # ZFS snapshots (iMac only)
  └── …
```

### Per-Host Hardware

Machine-specific hardware (GPU driver, kernel modules, boot loader, `networking.hostId`) lives in `hosts/<hostname>/hardware.nix`. The auto-generated `hardware-configuration.nix` (filesystem UUIDs, initrd modules) lives alongside it in `hosts/<hostname>/`.

### Home Manager Profiles

Home Manager is split into two layers:
- `home/common.nix` — programs present on every host (git, fish, starship, emacs, vscode, packages)
- `home/<hostname>.nix` — imports `common.nix` and adds host-specific programs (e.g., the full Hyprland + i3 desktop stack on the iMac)

### Adding a New Host

1. Create `hosts/<hostname>/hardware.nix` — boot loader, GPU driver, `networking.hostId`
2. Create `hosts/<hostname>/hardware-configuration.nix` — output of `nixos-generate-config`
3. Create `hosts/<hostname>/configuration.nix` — import `modules/common.nix` and the modules you want
4. Create `home/<hostname>.nix` — import `home/common.nix` and any host-specific program modules
5. Add a `nixosConfigurations.<hostname>` entry to `flake.nix`

```bash
sudo nixos-rebuild switch --flake .#<hostname>
```

### External Devices

Each peripheral gets its own `.nix` + `.md` pair in `modules/devices/`. Import the `.nix` in the host's `configuration.nix` to enable it for that host.

### Home Manager

Home Manager runs as a NixOS module (no separate activation step needed). Program config lives in `home/programs/`; complex native-language configs live in `config/<program>/` and are sourced via `home.file`.

## Hosts

| Hostname | Machine | Desktop | ZFS | Notes |
|----------|---------|---------|-----|-------|
| `imac` | Late 2012 iMac 27-inch | Hyprland + i3 + GNOME | ✅ | Hybrid Intel/NVIDIA (Nouveau), Broadcom Wi-Fi — [README](./hosts/imac/README.md) |
| `mac-mini` | Early 2009 Mac Mini | XFCE | ❌ | Intel Core 2 Duo, NVIDIA 9400M (Nouveau), ext4 — [README](./hosts/mac-mini/README.md) |

## External Devices

| Device | Type | Config | Docs | Hosts |
|--------|------|--------|------|-------|
| Brother HL-L2300D | Network printer | [brother-printer.nix](./modules/devices/brother-printer.nix) | [brother-printer.md](./modules/devices/brother-printer.md) | imac, mac-mini |
| Brother MFC-J410W | Network scanner | [brother-scanner.nix](./modules/devices/brother-scanner.nix) | [brother-scanner.md](./modules/devices/brother-scanner.md) | imac, mac-mini |

## Core Tools

- **Compositor:** Hyprland (Wayland) + i3 (X11 fallback) on iMac; XFCE on mac-mini
- **Login Manager:** Ly TUI
- **Terminals:** Alacritty, Foot
- **Shell:** Fish
- **Editor:** Emacs (declarative packages via `emacsWithPackages`), VS Code
- **Snapshots:** Sanoid (automated ZFS snapshot management, every 15 min — iMac only)

## Build & Deploy

```bash
# Rebuild and switch — iMac
sudo nixos-rebuild switch --flake .#imac

# Rebuild and switch — Mac Mini
sudo nixos-rebuild switch --flake .#mac-mini

# Test without making it the boot default
sudo nixos-rebuild test --flake .#imac

# Build without activating
sudo nixos-rebuild build --flake .#imac

# Update flake inputs to latest
nix flake update

# Garbage-collect old generations
sudo nix-collect-garbage -d
```

## Workflow

1. **System changes** → edit files under `modules/`, `hosts/`, or the relevant `hosts/<hostname>/configuration.nix` → `sudo nixos-rebuild switch --flake .#<hostname>`
2. **User/program changes** → edit files in `home/programs/` or `home/<hostname>.nix` → same rebuild picks them up
3. **Add a device to one host** → import the device's `.nix` in that host's `configuration.nix`
4. **Add a device to all hosts** → import the device's `.nix` in each host's `configuration.nix`
5. **Commit** → `git add . && git commit -m "…"` to track history

"Turning legacy hardware into future-proof Linux workstations, one flake at a time."