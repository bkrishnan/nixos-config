{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    satty
  ];

  # Satty configuration
  home.file.".config/satty/config.toml" = {
    text = ''
      [general]
      output-filename = "Pictures/Screenshots/%Y-%m-%d_%H-%M-%S.png"
      copy-command = "wl-copy"
      initial-tool = "brush"
      actions-on-enter = ["save-to-clipboard", "save-to-file"]
    '';
  };

  # Create Screenshots directory if it doesn't exist
  home.activation.createScreenshotsDir = ''
    mkdir -p $HOME/Pictures/Screenshots
  '';
}
