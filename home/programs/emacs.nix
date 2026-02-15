{ pkgs, lib, config, ... }:

let
  # Create custom Emacs build with all packages pre-loaded
  # Following NixOS manual: https://nixos.org/manual/nixos/stable/#module-services-emacs-running
  emacsWithPackages = pkgs.emacsPackages.withPackages (epkgs: with epkgs; [
    # Core completion and UI enhancements
    vertico
    marginalia
    orderless

    # Org-mode and extensions
    org
    org-roam
    denote

    # Themes
    ef-themes
    modus-themes
  ]);
  
  # Read the init.el file content for use in programs.emacs.init
  initElContent = builtins.readFile ../../config/emacs/init.el;
in
{
  # Enable Emacs via programs.emacs module (declarative package management)
  # Per NixOS documentation, this is the recommended approach for user-level Emacs
  programs.emacs = {
    enable = true;
    # Use the custom build with all packages pre-loaded
    package = emacsWithPackages;
  };

  # Use Home Manager's programs.emacs.init to actually load the configuration
  # This ensures init.el is properly executed during Emacs startup
  home.file.".emacs.d/init.el" = {
    source = ../../config/emacs/init.el;
  };

  # Startup optimization via early-init.el
  # Loaded before normal initialization sequence
  home.file.".emacs.d/early-init.el" = {
    text = ''
      ;; Disable package.el in favor of declarative Nix package management
      ;; Per NixOS manual: use (setq package-archives nil) for Nix-managed packages
      (setq package-enable-at-startup nil)
      (setq package-archives nil)

      ;; Increase garbage collection threshold for faster startup
      (setq gc-cons-threshold 10000000)
      (setq gc-cons-percentage 0.1)
      (add-hook 'emacs-startup-hook
                (lambda ()
                  (setq gc-cons-threshold 1000000
                        gc-cons-percentage 0.1)))

      ;; Disable GUI elements early to reduce initialization overhead
      (menu-bar-mode -1)
      (tool-bar-mode -1)
      (scroll-bar-mode -1)
      (blink-cursor-mode -1)
    '';
  };
}
