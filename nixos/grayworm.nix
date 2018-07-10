{ pkgs, ... }:

let
  # TODO: pin external repos bellow
  # TODO: until https://github.com/NixOS/nixos-hardware/pull/60 gets merged
  # nixos-hardware = builtins.fetchTarball https://github.com/NixOS/nixos-hardware/archive/master.tar.gz;
  nixos-hardware = builtins.fetchTarball https://github.com/azazel75/nixos-hardware/archive/master.tar.gz;
  nixpkgs-mozilla = builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz;

  luksdevice = {};
  luksdevice.name = "root";
  luksdevice.device = "/dev/disk/by-partlabel/cryptroot";

in {

  imports = [ "${nixos-hardware}/lenovo/thinkpad/x1/6th-gen/QHD/default.nix" ];

  boot.loader.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;

  boot.supportedFilesystems = [ "zfs" ];

  boot.zfs.devNodes = "/dev/mapper";
  boot.zfs.forceImportAll = true;
  boot.zfs.forceImportRoot = true;

  fileSystems."/".device = "rpool/ROOT";
  fileSystems."/".encrypted.blkDev = "/dev/disk/by-partlabel/cryptroot";
  fileSystems."/".encrypted.enable = true;
  fileSystems."/".fsType = "zfs";
  fileSystems."/boot".device = "/dev/disk/by-partlabel/efiboot";
  fileSystems."/boot".fsType = "vfat";
  fileSystems."/home".device = "rpool/HOME";
  fileSystems."/home".fsType = "zfs";

  nix.maxJobs = 8;

  nixpkgs.overlays = [ (import nixpkgs-mozilla) ];

  services.zfs.autoScrub.enable = true;
  services.zfs.autoSnapshot.enable = true;
}
