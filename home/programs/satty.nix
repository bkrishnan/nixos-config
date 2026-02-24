{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    satty
  ];

  # Satty configuration
  home.file.".config/satty/config.toml" = {
    text = ''
      [general]
      output-filename = "Pictures/Screenshots/%Y-%m-%d_%H-%M-%S.png"
      copy-command = "${pkgs.wl-clipboard}/bin/wl-copy"
      initial-tool = "arrow"
      annotation-size-factor = 0.5
      actions-on-enter = ["save-to-clipboard", "save-to-file"]
      early-exit = true
      default-hide-toolbars = true
    '';
  };

  # Create Screenshots directory if it doesn't exist
  home.activation.createScreenshotsDir = ''
    mkdir -p $HOME/Pictures/Screenshots
  '';
}
