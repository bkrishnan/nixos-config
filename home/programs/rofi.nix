{pkgs, ...}: {
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;

    # Apply the rounded-nord-dark theme
    theme = "/home/bkrishnan/.config/rofi/rounded-nord-dark.rasi";

    # rofi-calc plugin for live calculations (SUPER+C)
    plugins = [pkgs.rofi-calc];

    extraConfig = {
      modi = "drun,window,calc";
      show-icons = true;
      drun-display-format = "{name}";
      window-format = "{w} · {c} · {t}";
      # Start in drun mode; Ctrl+Tab switches to calc
      display-drun = "Apps";
      display-window = "Windows";
      display-calc = "Calc";
    };
  };

  # Deploy the theme file where rofi can find it
  home.file.".config/rofi/rounded-nord-dark.rasi" = {
    source = ../../config/rofi/rounded-nord-dark.rasi;
  };
}
