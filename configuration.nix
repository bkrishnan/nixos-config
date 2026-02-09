# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelParams = [
   "nvidia-drm.modeset=1"
   "video=efifb:off"
  ];

  zramSwap = {
    enable = true;
    algorithm = "zstd";       # Highly recommended for a balance of speed and compression
    memoryPercent = 60;      # Percentage of total RAM to use for zram
    priority = 10;           # Set higher than disk swap priority (if any)
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
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    displayManager.gdm.wayland = false; # Crucial for legacy NVIDIA 470
    desktopManager.gnome.enable = true;
  };

  # 1. Enable NVIDIA drivers in X11
  services.xserver.videoDrivers = [ "nvidia" ];

  # 2. Configure NVIDIA settings
  hardware.nvidia = {
    # Fixes screen tearing and is required for some modern desktop features
    modesetting.enable = true; 
    
    # Use the 470 legacy driver branch specifically
    package = config.boot.kernelPackages.nvidiaPackages.legacy_470;

    # Optional: Open the settings menu (nvidia-settings)
    nvidiaSettings = true;
    
    # Power management can be "experimental" on older cards; 
    # keep false unless you have suspend/resume issues.
    powerManagement.enable = false;
  };

  # 3. Graphics/OpenGL settings (Now 'hardware.graphics' in 24.11)
  hardware.graphics = {
    enable = true;
    # Required for 32-bit games/apps (like Steam)
    enable32Bit = true; 
  };

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

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
    extraGroups = [ "networkmanager"  "wheel" "video" ];
    packages = with pkgs; [
      tree
    ];
    createHome = true;
  };

  services.gnome.gnome-keyring.enable = true;
  programs.ssh.startAgent = true;

  services.logrotate.enable = false;

  security.sudo.enable = true;

  # programs.firefox.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow proprietary drivers
  nixpkgs.config = {
    allowUnfree = true;
    nvidia.acceptLicense = true;
    # Use a predicate so you don't have to update the version string manually
    allowInsecurePredicate = pkg: builtins.elem (lib.getName pkg) [
      "broadcom-sta"
    ];
  };

  # Boot with Broadcom drivers
  boot.initrd.kernelModules = [ "wl"];
  boot.kernelModules = [ "wl" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];

  # Optional: Blacklist conflicting open-source drivers
  boot.blacklistedKernelModules = [ "b43" "bcma" "brcmsmac" "ssb" ];


  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    git
    fish
    emacs
    vim
    google-chrome
    vscode
  ];

  # Optional: Enable Wayland support for Chrome/Electron apps
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # 2. Enable Fish properly (NixOS needs this to set up completions/paths)
  programs.fish.enable = true;

  # 3. Set Fish as the default shell for your user
  users.users.bkrishnan.shell = pkgs.fish;

  # 4. Optional: Enable Direnv (Great for Emacs/VSCode + Nix users)
  programs.direnv.enable = true;

  programs.git = {
    enable = true;
    config = {
      user = {
        name = "Bharath Krishnan";
        email = "bkrishnan@gmail.com";
      };
      init = {
        defaultBranch = "main";
      };
    };
  };


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
  system.stateVersion = "26.05"; # Did you read the comment?

}

