{ config, ... }:

{
  imports = [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix> ];

  boot.extraModulePackages = [
    config.boot.kernelPackages.tp_smapi
  ];
  boot.extraModprobeConfig = ''
    options snd_hda_intel index=1,0
    options thinkpad_acpi fan_control=1
  '';
  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.kernelParams = [ "libata.force=noncqtrim,noncq" ];

  powerManagement.scsiLinkPolicy = "max_performance";

  services.acpid.enable = true;

  services.thinkfan.enable = true;
  services.thinkfan.sensor = "/sys/class/hwmon/hwmon0/temp1_input";
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
