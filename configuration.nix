# System-level NixOS configuration.
# Machine-specific hardware tweaks live in hosts/<hostname>/hardware.nix.
# Per-device configs live in devices/*.nix.
# Help: configuration.nix(5), https://search.nixos.org/options, `nixos-help`
{pkgs, ...}: {
  imports = [
    # Auto-generated hardware scan — do not edit
    ./hardware-configuration.nix

    # iMac-specific: GPU drivers, Broadcom Wi-Fi, ZFS, kernel params
    ./hosts/imac/hardware.nix

    # External devices
    ./devices/brother-printer.nix
    ./devices/brother-scanner.nix
  ];

  # ZFS filesystem support
  boot.supportedFilesystems = ["zfs"];
  boot.zfs.package = pkgs.zfs;
  services.zfs.trim.enable = true;

  # zram swap — compressed in-memory swap, faster than disk and reduces writes
  zramSwap = {
    enable = true;
    algorithm = "zstd"; # Highly recommended for a balance of speed and compression
    memoryPercent = 60; # Percentage of total RAM to use for zram
    priority = 10; # Set higher than disk swap priority (if any)
  };

  networking.hostName = "imac";

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  services = {
    xserver.enable = true;
    displayManager.ly = {
      enable = true;
      settings = {
        # Direct Ly to the NixOS-generated Wayland session path
        wayland_spec = "/run/current-system/sw/share/wayland-sessions";
        # Also include X11 sessions for i3w
        x_spec = "/run/current-system/sw/share/xsessions";
      };
    };
    displayManager.gdm.wayland = false;
    desktopManager.gnome.enable = true;
  };

  # Enable the i3 window manager alongside GNOME
  services.xserver.windowManager.i3 = {
    enable = true;
    package = pkgs.i3;
  };

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.bkrishnan = {
    isNormalUser = true;
    description = "Bharath Krishnan";
    extraGroups = ["networkmanager" "wheel" "video" "scanner" "lp"];
    createHome = true;
  };

  services.gnome.gnome-keyring.enable = true;

  services.logrotate.enable = false;

  security.sudo.enable = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Home Manager configuration
  home-manager.backupFileExtension = "backup";

  nixpkgs.config = {
    allowUnfree = true;
    nvidia.acceptLicense = true;
  };

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    zfs # ZFS CLI tools (zpool, zfs, etc.)

    # Desktop / X11 tools
    dmenu # Application launcher (i3)
    rofi # Alternative application launcher
    picom # Compositor for transparency and shadows
    xorg.xrandr # Screen resolution utility
    arandr # Graphical display configuration tool
    lxappearance # GTK theme switcher

    # Wayland / Hyprland tools
    wofi # App launcher
    waybar # Status bar

    # Terminals
    alacritty
    foot # Wayland-native terminal
  ];

  programs.hyprland.enable = true;

  # Install fonts system-wide
  fonts.packages = with pkgs; [
    jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
    font-awesome
  ];

  # Enable Fish at the system level
  programs.fish.enable = true;

  # Set Fish as the default shell for the user
  users.users.bkrishnan.shell = pkgs.fish;

  # Enable Direnv
  programs.direnv.enable = true;

  # Allow non-Nix binaries to be run gracefully (Eg. Shopify's javy)
  programs.nix-ld.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  services.tailscale = {
    enable = true;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?
}
