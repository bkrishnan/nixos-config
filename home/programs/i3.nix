{ pkgs, ... }:

{
  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3;
    config = {
      modifier = "Mod4";
      
      terminal = "alacritty";
      
      fonts = {
        names = [ "pango:System San Francisco Display" ];
        size = 12.0;
      };

      floating.modifier = "Mod4";

      startup = [
        {
          command = "dex --autostart --environment i3";
          always = false;
          notification = false;
        }
        {
          command = "xss-lock --transfer-sleep-lock -- i3lock --nofork";
          always = false;
          notification = false;
        }
        {
          command = "nm-applet";
          always = false;
          notification = false;
        }
        {
          command = "nitrogen --restore";
          always = false;
          notification = false;
        }
        {
          command = "xrandr --output DP-0 --off --output DP-1 --mode 1920x1080 --pos 0x180 --rotate normal --output DP-2 --primary --mode 2560x1440 --pos 1920x0 --rotate normal --output DP-3 --off --output DP-4 --off";
          always = true;
          notification = false;
        }
      ];

      keybindings = {
        "Mod4+Return" = "exec alacritty";
        "Mod4+Shift+q" = "kill";
        "Mod4+d" = "exec rofi -show drun";
        
        # Change focus
        "Mod4+j" = "focus left";
        "Mod4+k" = "focus down";
        "Mod4+l" = "focus up";
        "Mod4+semicolon" = "focus right";
        
        # Arrow keys for focus
        "Mod4+Left" = "focus left";
        "Mod4+Down" = "focus down";
        "Mod4+Up" = "focus up";
        "Mod4+Right" = "focus right";
        
        # Move focused window
        "Mod4+Shift+j" = "move left";
        "Mod4+Shift+k" = "move down";
        "Mod4+Shift+l" = "move up";
        "Mod4+Shift+semicolon" = "move right";
        
        # Arrow keys for move
        "Mod4+Shift+Left" = "move left";
        "Mod4+Shift+Down" = "move down";
        "Mod4+Shift+Up" = "move up";
        "Mod4+Shift+Right" = "move right";
        
        # Split
        "Mod4+h" = "split h";
        "Mod4+v" = "split v";
        
        # Fullscreen
        "Mod4+f" = "fullscreen toggle";
        
        # Layout
        "Mod4+s" = "layout stacking";
        "Mod4+w" = "layout tabbed";
        "Mod4+e" = "layout toggle split";
        
        # Floating
        "Mod4+Shift+space" = "floating toggle";
        "Mod4+space" = "focus mode_toggle";
        
        # Focus parent/child
        "Mod4+a" = "focus parent";
        
        # Workspaces
        "Mod4+1" = "workspace number 1: ";
        "Mod4+2" = "workspace number 2";
        "Mod4+3" = "workspace number 3";
        "Mod4+4" = "workspace number 4";
        "Mod4+5" = "workspace number 5";
        "Mod4+6" = "workspace number 6";
        "Mod4+7" = "workspace number 7";
        "Mod4+8" = "workspace number 8";
        "Mod4+9" = "workspace number 9";
        "Mod4+0" = "workspace number 10";
        
        # Move to workspace
        "Mod4+Shift+1" = "move container to workspace number 1: ";
        "Mod4+Shift+2" = "move container to workspace number 2";
        "Mod4+Shift+3" = "move container to workspace number 3";
        "Mod4+Shift+4" = "move container to workspace number 4";
        "Mod4+Shift+5" = "move container to workspace number 5";
        "Mod4+Shift+6" = "move container to workspace number 6";
        "Mod4+Shift+7" = "move container to workspace number 7";
        "Mod4+Shift+8" = "move container to workspace number 8";
        "Mod4+Shift+9" = "move container to workspace number 9";
        "Mod4+Shift+0" = "move container to workspace number 10";
        
        # i3 management
        "Mod4+Shift+c" = "reload";
        "Mod4+Shift+r" = "restart";
        "Mod4+Shift+e" = "exec \"i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -B 'Yes, exit i3' 'i3-msg exit'\"";
        
        # Audio controls
        "XF86AudioRaiseVolume" = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +10% && killall -SIGUSR1 i3status";
        "XF86AudioLowerVolume" = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -10% && killall -SIGUSR1 i3status";
        "XF86AudioMute" = "exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle && killall -SIGUSR1 i3status";
        "XF86AudioMicMute" = "exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle && killall -SIGUSR1 i3status";
        
        # Screenshots and utilities
        "Print" = "exec flameshot gui";
        "Mod4+Shift+x" = "exec i3lock -t -i /home/bkrishnan/Pictures/Wallpapers/alphacoders/1351629.png";
        
        # Resize mode
        "Mod4+r" = "mode \"resize\"";
      };

      modes = {
        resize = {
          "j" = "resize shrink width 10 px or 10 ppt";
          "k" = "resize grow height 10 px or 10 ppt";
          "l" = "resize shrink height 10 px or 10 ppt";
          "semicolon" = "resize grow width 10 px or 10 ppt";
          
          "Left" = "resize shrink width 10 px or 10 ppt";
          "Down" = "resize grow height 10 px or 10 ppt";
          "Up" = "resize shrink height 10 px or 10 ppt";
          "Right" = "resize grow width 10 px or 10 ppt";
          
          "Return" = "mode \"default\"";
          "Escape" = "mode \"default\"";
          "Mod4+r" = "mode \"default\"";
        };
      };

      bars = [
        {
          statusCommand = "SCRIPT_DIR=~/.config/i3blocks/scripts i3blocks";
          colors = {
            background = "#2f343f";
            statusline = "#f3f4f5";
          };
        }
      ];
    };
  };

  # Additional packages needed for i3 setup
  home.packages = with pkgs; [
    nitrogen
    flameshot
    i3lock
  ];
}
