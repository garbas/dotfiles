{ pkgs, ... }:

{
  imports =
    [ ./hw/lenovo-x220.nix 
      (import ./rok.nix { i3_tray_output = "LVDS1"; })
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
  fileSystems."/tmp".options = "nosuid,nodev,relatime";

  nix.extraOptions = ''
    build-cores = 4
  '';
  nix.maxJobs = 4;

  networking.hostName = "oskar";

  #i18n.consoleFont = "lat9w-16";
}
