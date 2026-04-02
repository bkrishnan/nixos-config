# Home Manager — bkrishnan on the Mac Mini.
# Imports common programs only; XFCE is managed at the system level.
# Add host-specific program modules here as needed.
{...}: {
  imports = [
    ./common.nix
  ];
}
