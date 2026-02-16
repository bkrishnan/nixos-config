{ ... }:

{
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
      };

      background = [
        {
          path = "/home/bkrishnan/Downloads/1367250.jpeg"; # supports png, jpg, webp (or "screenshot")
          color = "rgba(25, 20, 20, 1.0)";
          # blur_passes = 2;
        }
      ];

      input-field = [
        {
          size = "200, 50";
          position = "0, -80";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(202, 158, 230)";
          inner_color = "rgb(91, 108, 142)";
          outer_color = "rgb(24, 25, 38)";
          outline_thickness = 5;
          placeholder_text = "Password...";
          shadow_passes = 2;
        }
      ];
    };
  };
}
