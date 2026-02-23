{lib, ...}: {
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        # Prevent multiple hyprlock instances if lock is triggered rapidly
        lock_cmd = "pidof hyprlock || hyprlock";

        # Lock before the system suspends so the screen is protected on wake
        before_sleep_cmd = "loginctl lock-session";

        # Re-enable displays after waking from suspend (avoids needing two
        # key-presses to wake the screen)
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        {
          # After 5 minutes idle -> lock the session via DBus.
          timeout = 300; # 5 minutes
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 330; # 5 min 30 s
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };

  # ── systemd service override ───────────────────────────────────────────────
  # By default Home Manager's hypridle unit starts on basic.target and checks
  # for WAYLAND_DISPLAY, which is not set that early in a non-systemd Hyprland
  # session. Overriding After= and clearing ConditionEnvironment= makes it
  # wait until graphical-session.target instead.
  # See: https://github.com/nix-community/home-manager/issues/5899
  systemd.user.services.hypridle = {
    Unit = {
      After = lib.mkForce "graphical-session.target";
      ConditionEnvironment = lib.mkForce "";
    };
  };
}
