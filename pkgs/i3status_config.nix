{ lib, base16, base16Theme }:

let
in ''

${builtins.readFile "${base16}/i3status/base16-${base16Theme}.i3status"}

  
order += "disk /"
order += "wireless wlp3s0"
order += "ethernet eth0"
order += "cpu_temperature 0"
order += "sysdata"
order += "time"
order += "battery_level 0"
order += "battery_level 1"

battery_level 0 {
  battery_id = 0
  notify_low_level = true
  format = "B0: {percent}% {icon}"
}

battery_level 1 {
  battery_id = 1
  notify_low_level = true
  format = "B1: {percent}% {icon}"
}

wireless wlp3s0 {
  format_up = "W: (%quality at %essid) %ip"
  format_down = "W: down"
}

ethernet eth0 {
  # if you use %speed, i3status requires root privileges
  format_up = "E: %ip (%speed)"
  format_down = "E: down"
}

disk "/" {
  format = "%free"
}

cpu_temperature 0 {
  format = "T: %degrees °C"
}

time {
  format = "%Y-%m-%d %H:%M:%S"
}

''
