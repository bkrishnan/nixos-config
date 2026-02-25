{pkgs, ...}: {
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;

    # Apply the rounded-nord-dark theme
    theme = "/home/bkrishnan/.config/rofi/rounded-nord-dark.rasi";

    extraConfig = {
      modi = "drun,window";
      show-icons = true;
      drun-display-format = "{name}";
      window-format = "{w} · {c} · {t}";
      display-drun = "Apps";
      display-window = "Windows";
    };
  };

  # Deploy the theme file where rofi can find it
  home.file.".config/rofi/rounded-nord-dark.rasi" = {
    source = ../../config/rofi/rounded-nord-dark.rasi;
  };
}
