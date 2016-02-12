{ ... }:

{
  imports = [ ./lenovo.nix ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" ];
  boot.kernelParams = [ "libata.force=noncqtrim,noncq" ];

  powerManagement.scsiLinkPolicy = "max_performance";

  services.xserver.xkbModel = "thinkpad60";
}
