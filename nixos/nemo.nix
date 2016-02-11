{ pkgs, ... }:

{
  imports =
    [ ./hw/lenovo-x250.nix 
      ./rok.nix
    ];

  boot.blacklistedKernelModules = [ "snd_pcsp" "pcspkr" ];
  boot.kernelModules = [ "fbcon" "intek_agp" "i915" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.zfsSupport = true;
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.devNodes = "/dev/mapper";
  boot.zfs.forceImportAll = true;
  boot.zfs.forceImportRoot = true;

  fileSystems."/".device = "rpool/ROOT";
  fileSystems."/".encrypted.enable = true;
  fileSystems."/".encrypted.label = "root_crypt";
  fileSystems."/".encrypted.blkDev = "/dev/sda2";
  fileSystems."/".fsType = "zfs";
  fileSystems."/boot".device = "/dev/sda1";
  fileSystems."/boot".fsType = "vfat";
  fileSystems."/home".device = "rpool/HOME";
  fileSystems."/home".fsType = "zfs";
  fileSystems."/tmp".device = "tmpfs";
  fileSystems."/tmp".fsType = "tmpfs";
  fileSystems."/tmp".options = "nosuid,nodev,relatime";
  fileSystems."/var".device = "rpool/VAR";
  fileSystems."/var".fsType = "zfs";
  fileSystems."/var".options = "defaults,noatime,acl";

  hardware.bluetooth.enable = true;
  hardware.pulseaudio.enable = true;

  # cksum /etc/machine-id | while read c rest; do printf "%x" $c; done
  networking.hostId = "5eb7479f";

  nix.maxJobs = 4;

  networking.hostName = "nemo";
  networking.extraHosts = ''
    127.0.0.1 nemo
    ::1 nemo
  '';

}
