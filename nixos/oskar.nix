{ pkgs, ... }:

{
  imports =
    [ ./hw/lenovo-x220.nix 
      (import ./marta.nix { })
    ];

  boot.initrd.kernelModules = [ "dm_mod" "dm-crypt" "ext4" "ecb" ];
  boot.initrd.luks.devices = [
    { name = "luksroot";
      device = "/dev/sda2";
      allowDiscards = true;
      }
  ];
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  fileSystems."/".label = "root";
  fileSystems."/boot".label = "boot";
  fileSystems."/tmp".device = "tmpfs";
  fileSystems."/tmp".fsType = "tmpfs";
  fileSystems."/tmp".options = [ "nosuid" "nodev" "relatime" ];

  services.xserver.videoDrivers = [ "intel" ];
  services.xserver.deviceSection = ''
    Option "Backlight" "intel_backlight"
    BusID "PCI:0:2:0"
  '';

  services.xserver.desktopManager.gnome3.enable = true;
  services.xserver.displayManager.gdm.enable = true;

  nix.extraOptions = ''
    build-cores = 4
  '';
  nix.maxJobs = 4;

  networking.hostName = "oskar";

  services.xserver.displayManager.slim.defaultUser = "marta";
  services.xserver.desktopManager.default = "gnome3";

}
