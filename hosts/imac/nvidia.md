# GPU Setup — iMac (Late 2012, 13,2)

This machine has **two GPUs**: a discrete NVIDIA GTX 680MX and an Intel HD 4000 iGPU. They serve distinct roles and are balanced via session environment variables. See [hardware.nix](./hardware.nix) for the full configuration.

## Hardware

| GPU | Architecture | Driver | Role |
|-----|-------------|--------|------|
| NVIDIA GTX 680MX | NVE4 (Kepler) | Nouveau | Display output |
| Intel HD 4000 | Ivy Bridge | i915 (kernel) | Hyprland compositor render + VA-API video decode |

## The Apple EFI iGPU Problem

Apple's EFI firmware hides the Intel HD 4000 from non-macOS operating systems. Without intervention, only the NVIDIA GPU is visible at boot.

**Fix**: Install [rEFInd](https://www.rodsbooks.com/refind/) as the boot manager and set `spoof_osx_version` to a macOS version string in `refind.conf`. This tricks the EFI into initialising both GPUs at POST, making the Intel iGPU visible to Linux.

Without rEFInd + this setting, `/dev/dri/card0` (Intel) will not appear and Hyprland will fall back to NVIDIA-only rendering, which has Wayland/GBM limitations.

## Why Nouveau Instead of the Proprietary NVIDIA 470 Driver?

The NVIDIA 470 driver is the last proprietary driver to support the GTX 680MX on Linux. It does **not** support GBM (Generic Buffer Manager), which is required by Wayland compositors including Hyprland. Attempting to run Hyprland with the 470 driver will fail.

Nouveau (NVE4 backend) does support GBM via Mesa, enabling a native Wayland session. The trade-off is slightly lower peak GPU performance compared to the proprietary driver, partially mitigated by the `NvBoost=1` kernel parameter.

The proprietary driver is explicitly blacklisted:
```nix
boot.blacklistedKernelModules = [ "nvidia" "nvidia_drm" "nvidia_modeset" ];
```

## GPU Load Balancing

```
┌──────────────────────────────────┐
│  Intel HD 4000 (i915)            │  ← Hyprland compositor renderer
│  /dev/dri/card0                  │  ← VA-API hardware video decode
└──────────────┬───────────────────┘
               │ PCIe
┌──────────────┴───────────────────┐
│  NVIDIA GTX 680MX (Nouveau/NVE4) │  ← Display scanout (drives the monitor)
│  /dev/dri/card1                  │
└──────────────────────────────────┘
```

Controlled via session environment variables in `hardware.nix`:

```nix
AQ_DRM_DEVICES = "/dev/dri/card0:/dev/dri/card1";  # Intel first → Hyprland renders on Intel
LIBVA_DRIVER_NAME = "i915";                         # Force VA-API to use Intel for video decode
```

`AQ_DRM_DEVICES` is consumed by Aquamarine (Hyprland's rendering backend). It picks the **first** device in the list as its primary renderer — so listing `card0` (Intel) first means Hyprland renders on the Intel GPU. NVIDIA handles display output only.

## How Hyprland Works on This Machine

Hyprland requires a GPU with functioning KMS/DRM/GBM support. Nouveau on NVE4 provides this, but the proprietary NVIDIA driver does not. The setup works as follows:

1. **rEFInd** unlocks the Intel iGPU at boot by spoofing macOS to Apple's EFI.
2. **Hyprland** is pointed at `card0` (Intel) via `AQ_DRM_DEVICES`, so all compositor rendering (windows, animations, effects) happens on the Intel GPU.
3. **NVIDIA (Nouveau)** drives the display — it handles the scanout (pushing pixels to the monitor) but does not render the compositor itself.
4. **VA-API** decode for browsers (Chrome, VS Code, etc.) is routed to Intel via `LIBVA_DRIVER_NAME=i915`, using `intel-vaapi-driver`.

This sidesteps the Nouveau/Wayland GBM edge cases by keeping Intel as the primary renderer, while still using NVIDIA's display output capability.

## Video Decode (VA-API)

Chrome, Firefox, and Electron apps can use Intel's VA-API hardware decoder for video playback:

- `intel-vaapi-driver` — VA-API driver for Intel iGPU
- `libvdpau-va-gl` — VDPAU → VA-API bridge for apps that speak VDPAU
- `LIBVA_DRIVER_NAME=i915` — forces VA-API to use Intel

Verify with:
```bash
vainfo                  # Shows supported decode profiles
sudo intel_gpu_top      # Watch Intel GPU utilisation during video
```

## Verification Commands

```bash
# Confirm Intel is the active GL renderer for Hyprland
glxinfo | grep "OpenGL renderer"

# Confirm Intel VA-API decode is working
vainfo

# Watch Intel GPU during video playback
sudo intel_gpu_top

# Watch NVIDIA GPU activity
nvtop

# List all DRM devices (verify card0 = Intel, card1 = NVIDIA)
ls -la /dev/dri/
lspci | grep -i vga
```
