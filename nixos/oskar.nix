{ config, pkgs, lib, ... }:

{
  imports =
    [ ./hw/lenovo-x220.nix 
      ./marta.nix
    ];

  services.thinkfan.enable = lib.mkForce false;

  boot.initrd.kernelModules =
    [ "dm_mod" "dm-crypt" "ext4" "ecb" ];
  boot.initrd.luks.devices = [
    { name = "luksroot";
      device = "/dev/sda2";
      allowDiscards = true;
      }
  ];

  fileSystems."/".label = "root";
  fileSystems."/boot".label = "boot";

  services.xserver.videoDrivers = [ "intel" ];
  services.xserver.deviceSection = ''
    Option "Backlight" "intel_backlight"
    BusID "PCI:0:2:0"
  '';

  nix.extraOptions = ''
    build-cores = 4
  '';
  nix.maxJobs = 4;

  networking.hostName = "oskar";

}
