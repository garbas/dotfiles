# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

inputs:
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/profiles/qemu-guest.nix")
      inputs.home-manager.nixosModules.home-manager
      (import ./profiles/wayland.nix inputs)
    ];

  # -- HARDWARE ---------------------------------------------------------------

  boot.initrd.availableKernelModules = [ "xhci_pci" "virtio_pci" "usbhid" "usb_storage" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/2d3a4959-87f9-406d-86f4-3e9bcc1db548";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/0DB0-40C8";
      fsType = "vfat";
    };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp0s1.useDHCP = lib.mkDefault true;

  nix.settings.max-jobs = lib.mkDefault 8;
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  # -- HOME MANAGER -----------------------------------------------------------

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.rok = import ./../homeConfigurations/wayland.nix {
    username = "rok";
    email = "rok@garbas.si";
    fullname = "Rok Garbas";
    sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICZr0HtRTIngjPGi4yliL4vffUYxx1OMCcfHcecAhgO5 rok@cercei";
  };

  # ---------------------------------------------------------------------------

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}

