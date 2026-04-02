# PLACEHOLDER — Replace with the actual output of nixos-generate-config
#
# During NixOS installation, run:
#   nixos-generate-config --root /mnt
#
# Then copy the generated /mnt/etc/nixos/hardware-configuration.nix here.
{
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  # Hardware-specific configuration will be populated by nixos-generate-config.
  # (fileSystems, boot.initrd.availableKernelModules, nixpkgs.hostPlatform, etc.)
}
