{ lib, ... }:

{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock"; # avoid starting multiple instances
        before_sleep_cmd = "loginctl lock-session"; # lock before suspend
        after_sleep_cmd = "hyprctl dispatch dpms on"; # turn on display after sleep
      };

      listener = [
        {
          timeout = 300; # 5 minutes
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 330; # 5.5 minutes
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };

  # Fix for WAYLAND_DISPLAY not being set during systemd service startup
  # See: https://github.com/nix-community/home-manager/issues/5899
  systemd.user.services.hypridle = {
    Unit = {
      After = lib.mkForce "graphical-session.target";
      ConditionEnvironment = lib.mkForce "";
    };
  };
}
