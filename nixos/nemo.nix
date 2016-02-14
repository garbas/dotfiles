{ pkgs, ... }:

{
  imports =
    [ ./hw/lenovo-x250.nix 
      (import ./rok.nix { i3_tray_output = "eDP1"; })
    ];

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

  # hostId needed for zsh
  # cksum /etc/machine-id | while read c rest; do printf "%x" $c; done
  networking.hostId = "5eb7479f";

  nix.extraOptions = ''
    build-cores = 4
  '';
  nix.maxJobs = 4;

  networking.hostName = "nemo";

}
