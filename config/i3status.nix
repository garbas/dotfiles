{ writeText, theme }:

let
  self = brightness: writeText "i3status-config-${brightness}"
    ''
      ${builtins.replaceStrings
        [ "general {" "color_bad = \""]
        [ "general {\n    interval = 5" "color_bad = \"#" ]
        (builtins.readFile "${theme}/i3status.${brightness}")
        }

      order += "disk /"

      disk "/" {
        format = "%free"
      }

      order += "wireless wlp3s0"

      wireless wlp3s0 {
        format_up = "W: (%quality at %essid) %ip"
        format_down = "W: down"
      }

      order += "ethernet enp0s25"

      ethernet enp0s25{
        # if you use %speed, i3status requires root privileges
        format_up = "E: %ip (%speed)"
        format_down = "E: down"
      }

      order += "cpu_temperature 0"

      cpu_temperature 0 {
        format = "T: %degrees °C"
      }

      order += "sysdata"

      order += "battery_level 0"

      battery_level 0 {
        battery_id = 0
        notify_low_level = true
        format = "B0: {percent}% {icon}"
      }

      order += "battery_level 1"

      battery_level 1 {
        battery_id = 1
        notify_low_level = true
        format = "B1: {percent}% {icon}"
      }

      order += "time"

      time {
        format = "%Y-%m-%d %H:%M:%S"
      }

    '';

in {
  light = self "light";
  dark = self "dark";
  packages = {};
}
