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
  luksdevice.preLVM = true;

in {

  imports = [ "${nixos-hardware}/lenovo/thinkpad/x1/6th-gen/QHD/default.nix" ];

  nix.maxJobs = 8;
  nixpkgs.overlays = [ (import nixpkgs-mozilla) ];
  boot.initrd.luks.devices = [ luksdevice ];
  boot.loader.systemd-boot.enable = true;

  fileSystems."/".device = "rpool/ROOT";
  fileSystems."/".encrypted.blkDev = "/dev/sda2";
  fileSystems."/".encrypted.enable = true;
  fileSystems."/".encrypted.label = "root_crypt";
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
}
