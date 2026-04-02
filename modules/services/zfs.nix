# ZFS filesystem support + zram compressed swap.
# Each host that imports this module must also declare a unique
# networking.hostId in its hardware.nix (required by ZFS):
#   networking.hostId = "<8-hex-chars>";  # head -c4 /dev/urandom | od -A none -t x4
{pkgs, ...}: {
  boot.supportedFilesystems = ["zfs"];
  boot.zfs.package = pkgs.zfs;
  services.zfs.trim.enable = true;

  # zram swap — compressed in-memory swap, faster than disk and reduces writes.
  zramSwap = {
    enable = true;
    algorithm = "zstd"; # Good balance of speed and compression ratio
    memoryPercent = 60; # Percentage of total RAM to use for zram
    priority = 10; # Higher than disk swap priority
  };

  environment.systemPackages = [pkgs.zfs]; # ZFS CLI tools (zpool, zfs, etc.)
}
