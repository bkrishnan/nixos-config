# iMac (Late 2012, 13,2) — Hardware-specific configuration
# Covers: Broadcom Wi-Fi, dual GPU (Nouveau + Intel), kernel params
{
  config,
  lib,
  pkgs,
  ...
}: {
  # ── Boot ──────────────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelParams = [
    "nouveau.config=NvBoost=1" # Prevent Nouveau GPU clock drops
    "nouveau.modeset=1"
    # Prevent Sabrent USB controller from crashing and resetting under the heavy I/O load of a ZFS send.
    "usb-storage.quirks=152d:a578:u"
  ];

  # Broadcom BCM4331 Wi-Fi (requires proprietary broadcom-sta)
  boot.initrd.kernelModules = ["wl" "i915"];
  boot.kernelModules = ["wl"];
  boot.extraModulePackages = [config.boot.kernelPackages.broadcom_sta];

  # Blacklist conflicting open-source Wi-Fi drivers and proprietary NVIDIA
  boot.blacklistedKernelModules = [
    "b43"
    "bcma"
    "brcmsmac"
    "ssb" # Conflict with broadcom-sta
    "nvidia"
    "nvidia_drm"
    "nvidia_modeset" # Use Nouveau instead
  ];

  # ZFS requires a unique hostId per machine — generate with: head -c4 /dev/urandom | od -A none -t x4
  networking.hostId = "8425e349";

  # ── ZFS Data Pool ─────────────────────────────────────────────────────────
  # rpool is not the root pool (root lives on ext4), so it must be explicitly
  # imported. requestEncryptionCredentials is a list so that ONLY rpool/data
  # (and its key-inheriting children) are decrypted at boot; other datasets in
  # rpool that have separate keys, or whose canmount=noauto, are left alone.
  #
  # NOTE: Unencrypted datasets (or those that share rpool/data's key) in rpool
  # will still mount if their canmount property is "on". To suppress unwanted
  # mounts, run once per dataset: zfs set canmount=noauto <dataset>
  boot.zfs.extraPools = ["rpool"];
  # rpool is the encryption root for all datasets in the pool (single shared key,
  # keylocation=prompt). Specifying ["rpool"] generates a boot-time key-loading
  # unit that prompts for the passphrase before Ly starts. Child datasets mount
  # based on their individual canmount properties — see below.
  boot.zfs.requestEncryptionCredentials = ["rpool"];

  # ── GPU: NVIDIA GTX 680MX (Nouveau/NVE4) — Primary Renderer ──────────────
  # Apple EFI hides the Intel iGPU; rEFInd with spoof_osx_version unlocks it.
  # Proprietary NVIDIA 470 driver lacks Wayland/GBM support, so we use Nouveau.
  services.xserver.videoDrivers = ["nouveau"];
  hardware.nvidia.modesetting.enable = true;

  # ── GPU: Intel HD 4000 (i915) — VA-API Video Decoder ─────────────────────
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Required for 32-bit apps (e.g. Steam)
    extraPackages = with pkgs; [
      intel-vaapi-driver # VA-API for Intel iGPU
      libvdpau-va-gl # VDPAU → VA-API bridge for older apps
      mesa # Required by Nouveau
    ];
  };

  # ── Session Environment — GPU Load Balancing ──────────────────────────────
  # card0 = Intel HD 4000, card1 = NVIDIA GTX 680MX
  environment.sessionVariables = {
    # Force Intel to render the desktop; NVIDIA just drives the display output
    AQ_DRM_DEVICES = "/dev/dri/card0:/dev/dri/card1";

    # Force Chrome/Electron/Firefox to use Intel for hardware video decode
    LIBVA_DRIVER_NAME = "i915";

    # Wayland compatibility flags
    NIXOS_OZONE_WL = "1";
    MOZ_ENALBE_WAYLAND = "1";
    SDL_VIDEODRIVER = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    CLUTTER_BACKEND = "wayland";
  };

  # ── System Packages (iMac-specific monitoring tools) ─────────────────────
  environment.systemPackages = with pkgs; [
    pciutils # lspci — verify GPU/PCI layout
    mesa-demos # glxinfo — confirm active renderer
    libva-utils # vainfo — verify VA-API / Intel decode
    nvtopPackages.full # GPU activity monitor (NVIDIA + Intel)
    intel-gpu-tools # intel_gpu_top — Intel iGPU usage
  ];

  # ── Nixpkgs overrides (iMac-specific insecure allowance) ─────────────────
  # broadcom-sta is marked insecure; allow it by package name so the version
  # string doesn't need updating on each nixpkgs bump.
  nixpkgs.config.allowInsecurePredicate = pkg:
    builtins.elem (lib.getName pkg) ["broadcom-sta"];
}
