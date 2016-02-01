{ pkgs, config, modulesPath, ...}:
{
  hardware.bluetooth.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.enableAllFirmware = true;
  #hardware.firmware = [ pkgs.firmwareLinuxNonfree ];
  #hardware.firmware = [ pkgs.iwlwifi6000g2aucode ];
  services.xserver.videoDrivers = [ "intel" ];
  boot.initrd.kernelModules = [
    # rootfs, hardware specific
    "ahci"
    "aesni-intel"
    # proper console asap
    "fbcon"
    "i915"
  ];
  boot.initrd.availableKernelModules = [
    "scsi_wait_scan"
  ];

  # XXX: how can we load on-demand for qemu-kvm?
  boot.kernelModules = [
    "tp-smapi"
    "kvm-intel"
    "msr"
  ];

  boot.extraModprobeConfig = ''
      options sdhci debug_quirks=0x4670
      options thinkpad_acpi fan_control=1
    '';

  boot.extraModulePackages = [
      config.boot.kernelPackages.tp_smapi
  ];

  # disabled for fbcon and i915 to kick in or to disable the kernelParams
  # XXX: investigate
  boot.vesa = false;

  nix.extraOptions = ''
    build-cores = 4
  '';
  nix.maxJobs = 4;

  services.xserver.xkbModel = "thinkpad60";

  services.thinkfan.enable = true;
  services.thinkfan.sensor = "/sys/class/hwmon/hwmon1/temp1_input";
  services.thinkfan.levels = ''
    (0, 0, 45)
    (1, 40, 60)
    (2, 45, 65)
    (3, 50, 75)
    (4, 55, 80)
    (5, 60, 85)
    (7, 65, 32767)
  '';
}
