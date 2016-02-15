{ config, ...}:

{

  imports = [ ./lenovo.nix ];

  services.thinkfan.sensor = "/sys/class/hwmon/hwmon0/temp1_input";

  services.xserver.xkbModel = "thinkpad60";
}
