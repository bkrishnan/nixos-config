# Shared system-level configuration — imported by every host.
# Does NOT include: hostname, boot loader, display manager, desktop environments,
# ZFS/storage, or optional services (ssh, tailscale, avahi). Those live in
# their own modules and are imported per-host.
{pkgs, ...}: {
  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.bkrishnan = {
    isNormalUser = true;
    description = "Bharath Krishnan";
    extraGroups = ["networkmanager" "wheel" "video" "scanner" "lp"];
    createHome = true;
    shell = pkgs.fish;
  };

  services.gnome.gnome-keyring.enable = true;

  services.logrotate.enable = false;

  security.sudo.enable = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Home Manager — preserve any existing dotfiles that conflict with HM-managed ones.
  home-manager.backupFileExtension = "backup";

  nixpkgs.config = {
    allowUnfree = true;
    nvidia.acceptLicense = true;
  };

  # Install fonts system-wide.
  fonts.packages = with pkgs; [
    jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
    font-awesome
  ];

  # Enable Fish at the system level.
  programs.fish.enable = true;

  # Enable Direnv.
  programs.direnv.enable = true;

  # Allow non-Nix binaries to be run gracefully (e.g. Shopify's javy).
  programs.nix-ld.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. Never change this unless performing a
  # deliberate migration.
  system.stateVersion = "25.11";
}
