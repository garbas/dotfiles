{ pkgs, ... }:

let
  # TODO: pin external repos bellow
  # TODO: until https://github.com/NixOS/nixos-hardware/pull/60 gets merged
  # nixos-hardware = builtins.fetchTarball https://github.com/NixOS/nixpkgs-hardware/archive/master.tar.gz;
  nixos-hardware = builtins.fetchTarball https://github.com/azazel75/nixpkgs-hardware/archive/master.tar.gz;
  nixpkgs-mozilla = builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz;

  luksdevice = {};
  luksdevice.name = "root";
  luksdevice.device = "/dev/disk/by-partlabel/cryptroot";

in {

  imports = [ "${nixos-hardware}/lenovo/thinkpad/x1/6th-gen/QHD/default.nix" ];

  nix.maxJobs = 8;
  nixpkgs.overlays = [ (import nixpkgs-mozilla) ];
  boot.loader.systemd-boot.enable = true;
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.devNodes = "/dev/mapper";
  boot.zfs.forceImportAll = true;
  boot.zfs.forceImportRoot = true;
  #boot.zfs.enableUnstable = true;

  # TODO: configure them
  services.zfs.autoScrub.enable = true;
  services.zfs.autoSnapshot.enable = true;

  fileSystems."/".device = "rpool/ROOT";
  fileSystems."/".encrypted.blkDev = "/dev/disk/by-partlabel/cryptroot";
  fileSystems."/".encrypted.blkDev = "/dev/disk/by-partlabel/cryptroot";
  fileSystems."/".encrypted.enable = true;
  fileSystems."/".encrypted.enable = true;
  fileSystems."/".fsType = "zfs";
  fileSystems."/boot".device = "/dev/disk/by-partlabel/efiboot";
  fileSystems."/boot".fsType = "vfat";
  fileSystems."/home".device = "rpool/HOME";
  fileSystems."/home".fsType = "zfs";
}
