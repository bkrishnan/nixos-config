# GPU Setup — Mac Mini (Early 2009, MacMini3,1)

This machine has a **single integrated GPU**: the NVIDIA GeForce 9400M, part of the NVIDIA MCP79 chipset. It is always on — there is no discrete GPU, no iGPU to fall back to, and no way to power it down. See [hardware.nix](./hardware.nix) for the configuration.

## Hardware

| GPU | Architecture | Driver | Role |
|-----|-------------|--------|------|
| NVIDIA GeForce 9400M | NV50 (Tesla) | Nouveau (modesetting DDX) | Everything — display output, desktop rendering |

The 9400M is **not a discrete card**. It is integrated into the MCP79 southbridge chipset, which means:
- It always draws power regardless of load.
- There is no secondary GPU to offload work to.
- It cannot be disabled or powered down independently.

## Driver Choice: modesetting DDX (Not xf86-video-nouveau, Not 340xx)

Three options exist in theory; only one works in practice:

| Driver | Status | Reason |
|--------|--------|--------|
| `xf86-video-nouveau` | ❌ Broken | Missing `exaDriverAlloc` symbol on xorg-server 21.1.x — fails to load |
| NVIDIA 340.xx legacy | ❌ Not viable | Broken on Linux 6.x kernels in nixpkgs-unstable; also brings no meaningful benefit (see below) |
| `modesetting` DDX | ✅ In use | Built into xorg-server; uses Nouveau KMS/DRM at the kernel level; stable |

The `modesetting` DDX is Xorg's generic KMS-based display driver. It delegates all rendering to the Nouveau kernel DRM module, which provides Gallium3D OpenGL acceleration. Desktop compositing in XFCE's `xfwm4` is GPU-accelerated through this path.

Configuration in `hardware.nix`:
```nix
services.xserver.videoDrivers = ["modesetting"];
```

### Why 340xx Wouldn't Help Anyway

The NVIDIA 340.xx driver's VDPAU implementation on NV50/Tesla supports only **MPEG-2 and VC-1** hardware decode. YouTube serves **VP9** (and increasingly AV1) by default — neither is supported by 340xx VDPAU. Video decode would still happen in software on the CPU, unchanged.

## Why Hyprland Will Not Work on This Machine

The iMac is able to run Hyprland despite NVIDIA by offloading compositor rendering to its Intel HD 4000 iGPU (via `AQ_DRM_DEVICES`). That escape hatch does not exist here.

The Mac Mini 3,1 has **one GPU only**. Hyprland's wlroots-based backend requires a GPU with robust KMS/DRM/GBM support. On NV50/Tesla:

- Nouveau's GBM support for NV50 is minimal and unreliable in practice.
- Hyprland has **no CPU-only or software renderer mode** — it always requires a functioning DRM/GBM stack from a GPU.
- Common result when attempted: black screen or immediate crash at compositor startup.

**XFCE on X11** (the current setup) is the appropriate and stable desktop choice for this hardware.

## GPU Upgrade: Not Possible

The GeForce 9400M cannot be replaced with a more capable GPU. It is silicon integrated into the NVIDIA MCP79 southbridge chipset, soldered directly to the Mac Mini 3,1 logic board. There is no PCIe slot, no MXM slot, and no upgrade path of any kind — the GPU is the motherboard.

To get Hyprland, hardware video decode, or any modern GPU capability, a different machine is required. The Mac Mini 3,1 is suitable as a headless server or light XFCE workstation, but has reached its ceiling as a Linux desktop.

## Video Playback in Chrome / YouTube

Hardware video decode is **not available** on this machine for modern web codecs. Here is why and what to do about it:

### The Problem

YouTube serves VP9 video by default. The CPU (Intel Core 2 Duo, Penryn) has to decode this entirely in software, which causes:
- High CPU utilisation during playback
- Video stuttering, especially at 720p and above
- Fan spin-up

No driver change resolves this — it is a fundamental limitation of the codec and the hardware's decode capabilities.

### The Fix: Force H.264 in Chrome

H.264 is dramatically cheaper for this CPU to decode in software compared to VP9.

1. **Install the [enhanced-h264ify](https://chrome.google.com/webstore/detail/enhanced-h264ify/omkfmpieigblcllmkgbflkikinpkodlk) Chrome extension.** This blocks VP9 and AV1, forcing YouTube to serve H.264 instead. This is the single most effective improvement possible.

2. **Verify hardware acceleration is enabled** in Chrome at `chrome://settings/system` → "Use hardware acceleration when available" (should be checked by default).

3. **Optionally** stick to 480p or 360p for smoother playback at the cost of quality, since lower resolutions require less CPU even at H.264.

### Why Not VDPAU / VA-API?

Neither is useful here:
- **VDPAU** via the `va_gl` software bridge still decodes on the CPU — it adds overhead, not GPU acceleration.
- **VA-API** has no driver for NV50/Tesla. There is no `nouveau_drv_video` or equivalent.

The hardware simply cannot accelerate VP9, AV1, or any modern web video codec regardless of configuration.

## Verification Commands

```bash
# Confirm modesetting is the active DDX and Nouveau is the kernel driver
xrandr --listproviders
lspci -k | grep -A3 -i vga

# Confirm OpenGL works via Nouveau/Gallium
glxinfo | grep "OpenGL renderer"
```
