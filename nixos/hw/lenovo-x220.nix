{ config, ...}:

{

  imports = [ ./lenovo.nix ];

  #hardware.enableAllFirmware = true;
  ##hardware.firmware = [ pkgs.firmwareLinuxNonfree ];
  ##hardware.firmware = [ pkgs.iwlwifi6000g2aucode ];
  #services.xserver.videoDrivers = [ "intel" ];
  #boot.initrd.kernelModules = [
  #  # rootfs, hardware specific
  #  "ahci"
  #  "aesni-intel"
  #  # proper console asap
  #  "fbcon"
  #  "i915"
  #];
  #boot.initrd.availableKernelModules = [
  #  "scsi_wait_scan"
  #];

  ## XXX: how can we load on-demand for qemu-kvm?
  #boot.kernelModules = [
  #  "tp-smapi"
  #  "msr"
  #];

  ## disabled for fbcon and i915 to kick in or to disable the kernelParams
  ## XXX: investigate
  #boot.vesa = false;

  services.xserver.xkbModel = "thinkpad60";
}
