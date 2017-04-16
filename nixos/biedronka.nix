{ config, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
      ./common-new.nix
      ./family.nix
      ./brygida.nix
    ];

  boot.initrd.availableKernelModules =
    [ "uhci_hcd" "ehci_pci" "ata_piix" "ahci" "usb_storage" ];

  fileSystems."/".label = "root";
  fileSystems."/boot".label = "boot";

  swapDevices =
    [ { device = "/dev/disk/by-label/swap"; }
    ];

  nix.extraOptions = ''
    build-cores = 2
  '';
  nix.maxJobs = 2;

  networking.hostName = "biedronka";

}
