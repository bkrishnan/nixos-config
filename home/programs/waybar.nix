{ pkgs, ... }:
{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        modules-left = [ "hyprland/workspaces" "network" "pulseaudio" "tray" ];
        modules-center = [ "cpu" "memory" ];
        modules-right = [ "clock" ];
        clock = {
          format = "{:%a %d %b %H:%M}";
          on-click = "zenity --calendar";
        };
        cpu = {
          format = " {usage}%";
        };
        memory = {
          format = " {used:0.1f}G/{total:0.1f}G";
        };
        network = {
          format-wifi = "  {essid} ({signalStrength}%)";
          format-ethernet = "  {ifname}";
          format-disconnected = " Disconnected";
        };
        pulseaudio = {
          format = " {volume}%";
        };
        tray = {};
      };
    };
    style = ''
      * {
        font-family: JetBrains Mono, monospace;
        font-size: 20px;
      }
      window#waybar {
        background: #222D31;
        color: #F3F4F5;
        border-bottom: 2px solid #5e81ac;
      }
      #workspaces, #clock, #cpu, #memory, #network, #pulseaudio, #tray {
        margin-right: 16px;
      }
      #workspaces button {
        color: #fff;
      }
      #workspaces button.active {
        background: #5e81ac;
      }
      #clock {
        color: #a3be8c;
        font-weight: bold;
      }
      #cpu, #memory {
        color: #ebcb8b;
      }
      #network {
        color: #b48ead;
      }
      #pulseaudio {
        color: #88c0d0;
      }
      #tray {
        padding-right: 8px;
      }
    '';
  };

}
