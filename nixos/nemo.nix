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
  fileSystems."/tmp".options = [ "nosuid" "nodev" "relatime" ];
  fileSystems."/var".device = "rpool/VAR";
  fileSystems."/var".fsType = "zfs";
  fileSystems."/var".options = [ "defaults" "noatime" "acl" ];

  # hostId needed for zsh
  # cksum /etc/machine-id | while read c rest; do printf "%x" $c; done
  networking.hostId = "5eb7479f";

  nix.extraOptions = ''
    build-cores = 4
  '';
  nix.maxJobs = 4;

  networking.hostName = "nemo";

  services.xserver.displayManager.slim.defaultUser = "rok";
  services.xserver.desktopManager.default = "none";

  # XXX: is this needed
  services.xserver.videoDrivers = [ "intel" ];
  services.xserver.deviceSection = ''
    Option "Backlight" "intel_backlight"
    BusID "PCI:0:2:0"
  '';

  systemd.user.services.dunst.enable = true;
  systemd.user.services.udiskie.enable = true;
  systemd.user.services.i3lock-auto.enable = true;

  services.xserver.windowManager.default = "i3";
  services.xserver.windowManager.i3.enable = true;
  services.xserver.windowManager.i3.configFile = "/etc/i3-config";
}
