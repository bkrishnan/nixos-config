
# 🖥️ 2012 iMac (13,2) NixOS Hybrid-Wayland Config

This repository contains a highly optimized NixOS 25.11 configuration for the Late 2012 27-inch iMac. It successfully enables a stable, high-performance Hyprland (Wayland) environment by balancing the workload between the integrated Intel iGPU and the discrete NVIDIA GPU.

## 🚀 Configuration Highlights

### 1. Hardware "Unlocking"

**The Problem:** Apple's EFI firmware physically hides the Intel iGPU from non-macOS systems.

**The Fix:** Used the rEFInd boot manager with the `spoof_osx_version` hack to "trick" the hardware into initializing the Intel HD 4000 (Ivy Bridge) chip alongside the NVIDIA GPU.

### 2. Modern Graphics Stack

**Driver:** Migrated away from the legacy NVIDIA 470 proprietary driver (which lacks modern Wayland/GBM support).

**Solution:** Utilizes the open-source Mesa/Nouveau driver (NVE4) for the GTX 680MX. This enables native Wayland compatibility and modern Mesa (25.x+) features.

### 3. "Hybrid Harmony" Load Balancing

The system is tuned to distribute tasks across all available silicon:

- **NVIDIA GTX 680MX (NVE4):** Acts as the Primary Renderer. Handles the "Glass" (internal display), Hyprland animations, and UI drawing for buttery-smooth performance.
- **Intel HD 4000 (i915):** Acts as the Media Assistant. Handles hardware-accelerated video decoding (VA-API) for Chrome and Electron apps (VS Code) to keep the system efficient.
- **Intel i7 CPU:** Acts as the Orchestrator, managing the data flow between both GPUs over the internal PCIe bus.

### 4. Key Optimization Settings

**Wayland Stability:** Enabled `nouveau.config=NvBoost=1` to prevent GPU clock drops and `MUTTER_DEBUG_FORCE_KMS_MODE=simple` for stable window management.

**Electron Acceleration:** Forced `LIBVA_DRIVER_NAME=i915` and `NIXOS_OZONE_WL=1` to ensure Chrome and VS Code use the Intel iGPU for video tasks without crashing the NVIDIA-based desktop.

## 🛠️ Performance Verification

- **Desktop:** Confirmed stable Wayland session via Hyprland.
- **Renderer:** `glxinfo` confirms NVE4 (NVIDIA) is the primary engine.
- **Video:** `intel_gpu_top` confirms active Video/IMC spikes during 1080p playback, proving Intel-based acceleration is working in the background.

## 📦 Core Tools Included

- **Compositor:** Hyprland (Wayland)
- **Login Manager:** Ly TUI (configured for NixOS session paths)
- **Terminal:** Alacritty & Foot (GPU-accelerated, Wayland-native)
- **Monitoring:** nvtopPackages.full, intel-gpu-tools

## 🖨️ External Devices

### Brother HL-L2300D Printer
Network IPP printer shared from another machine. See [docs/devices/brother-printer.md](./docs/devices/brother-printer.md) for setup details.

### Brother MFC-J410W Scanner
Network scanner working via brscan4 driver. See [docs/devices/brother-scanner.md](./docs/devices/brother-scanner.md) for setup details.

## 🏗️ Configuration Structure

### NixOS Configuration

The main NixOS system configuration is defined in `configuration.nix`. This file contains:

- **System-level packages** installed globally across the system
- **Hardware configuration** including GPU drivers, kernel modules, and firmware
- **Services** such as X11, display managers, and window managers
- **Networking** and system settings
- **Boot parameters** and kernel module management

Key configurations in `configuration.nix`:
- NVIDIA and Intel graphics driver setup
- i3-gaps window manager alongside GNOME desktop
- i3 companion tools (i3blocks, dmenu, rofi, picom, etc.)
- GPU monitoring utilities (nvtop, intel-gpu-tools)

### Flakes Configuration

This project uses **Nix Flakes** for reproducible builds and dependency management. The `flake.nix` file:

- **Locks versions** of nixpkgs and home-manager to ensure consistency across rebuilds
- **Defines outputs** for the NixOS system configuration
- **Manages inputs** including nixpkgs (nixos-25.11 stable channel) and home-manager

To rebuild the system using flakes:
```bash
sudo nixos-rebuild switch --flake .#imac
```

### Home Manager Configuration

**Home Manager** is used to manage user-specific configurations and dotfiles. It provides a declarative way to configure:

- **User environment** variables and shell configurations
- **Program-specific settings** (terminal emulators, editors, window managers)
- **Dotfiles** and configuration files in a version-controlled manner
- **User packages** installed in the user profile

#### Home Manager Structure

- **`home.nix`** - Main Home Manager configuration file for user `bkrishnan`
- **`home/programs/`** - Directory containing modular Nix declarations for each program:
  - **`emacs.nix`** - Emacs with declarative package management via `emacsWithPackages`
  - **`i3.nix`** - i3-gaps window manager configuration with keybindings, workspaces, and startup commands
  - **`fish.nix`** - Fish shell configuration and aliases
  - **`git.nix`** - Git configuration (username, email, credentials)
  - **`vscode.nix`** - VS Code extensions and user settings
  - **`packages.nix`** - User-level package management
- **`config/`** - Raw configuration files (non-Nix) sourced by Home Manager modules:
  - **`config/emacs/init.el`** - Emacs Lisp configuration (use-package declarations, Org-mode setup, etc.)
  - Other program configs follow the same pattern as needed

#### Hybrid Configuration Approach

This repository uses a **hybrid Nix + static config files** approach for program configuration:

**Declarative (Nix) Layer:**
- Package installation and version pinning
- Simple settings and options (e.g., theme selection, keybindings)
- Per-program Nix modules in `home/programs/`

**Static Config Files Layer:**
- Complex, multi-line configurations (Org-mode capture templates, custom functions)
- Code written in the program's native language (Emacs Lisp, shell scripts, etc.)
- Stored in `config/<program>/` subdirectories
- Sourced by Home Manager modules via the `home.file` option

Example: **Emacs Configuration**
- `home/programs/emacs.nix` — Declares `emacsWithPackages` to pre-load all packages (vertico, org, denote, ef-themes, etc.) via Nix
- `config/emacs/init.el` — Contains Emacs Lisp configuration (use-package declarations, Org GTD setup, Denote bindings)
- The `.nix` file sources `init.el` via Home Manager: `home.file.".emacs.d/init.el".source = ../../config/emacs/init.el`

**Benefits:**
- Packages are pinned by Nix flakes, ensuring reproducibility
- Complex configurations stay readable in their native language
- Easy to version-control both declarative and static configs
- Scales well: just create a new `config/<program>/` folder as you add programs

#### Key Home Manager Features in This Config

- **Emacs** with declarative packages (vertico, marginalia, orderless, org, org-roam, denote, ef-themes) and custom Emacs Lisp configuration
- **i3-gaps setup** with custom keybindings (Super+D for app launcher, Super+Enter for terminal)
- **Alacritty terminal** configuration for X11/Wayland
- **Fish shell** setup with custom functions and environment variables
- **Git** configuration with automatic credential management
- **VS Code** with curated extensions (C++, Python, Go, Rust, etc.)

To manage Home Manager settings, edit files in `home/` or `home.nix` and rebuild:
```bash
home-manager switch --flake .#bkrishnan
```

Or rebuild the entire system (which includes Home Manager):
```bash
sudo nixos-rebuild switch --flake .#imac
```

## 🔄 Workflow

1. **System changes** → Edit `configuration.nix` or system-level files → `sudo nixos-rebuild switch --flake .#imac`
2. **User/program changes** → Edit files in `home/programs/` or `home.nix` → System rebuild picks up changes automatically
3. **Commit changes** → `git add .` and `git commit -m "message"` to track configuration history

---

"Turning a legacy iMac into a future-proof Linux workstation, one GPU at a time."