# ZFS filesystem support.
# Each host that imports this module must also declare a unique
# networking.hostId in its hardware.nix (required by ZFS):
#   networking.hostId = "<8-hex-chars>";  # head -c4 /dev/urandom | od -A none -t x4
{pkgs, ...}: {
  boot.supportedFilesystems = ["zfs"];
  boot.zfs.package = pkgs.zfs;
  boot.zfs.forceImportRoot = false;
  services.zfs.trim.enable = true;

  environment.systemPackages = [pkgs.zfs]; # ZFS CLI tools (zpool, zfs, etc.)
}
