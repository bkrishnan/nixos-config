# PLACEHOLDER — Replace with the actual hardware-configuration.nix from the ThinkPad.
#
# On the ThinkPad, run:
#   sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
# or copy the existing file:
#   cp /etc/nixos/hardware-configuration.nix ~/nixos-config/hosts/thinkpad/hardware-configuration.nix
#
# Commit the result before running `sudo nixos-rebuild switch --flake .#thinkpad`.
# This placeholder will cause the build to fail because the real disk UUIDs and
# filesystem mount points are unknown.
{
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # ── REPLACE EVERYTHING BELOW WITH THE GENERATED FILE ─────────────────────

  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "sr_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = [];
  boot.extraModulePackages = [];

  # Replace these UUIDs with the actual values from nixos-generate-config:
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/REPLACE-WITH-REAL-UUID";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/REPLACE-WITH-REAL-UUID";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  swapDevices = [];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
