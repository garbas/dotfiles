# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  custom_overlay = self: super: {
    neovim = super.neovim.override {
      vimAlias = true;
      configure = import ./vim_config.nix { inherit pkgs; };
    };
  };
in {
  imports =
    [ <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
    ];

  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "sd_mod" "sr_mod" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/2f54e8e6-ff9c-497a-88ea-ce159f6cd283";
      fsType = "ext4";
    };

  swapDevices = [ ];

  nix.maxJobs = lib.mkDefault 2;

  nixpkgs.overlays = [
    custom_overlay
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "floki";

  i18n = {
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "Europe/Berlin";


  environment.etc."gitconfig".source = ./gitconfig;
  environment.systemPackages = with pkgs; [
    git
    neovim
    termite.terminfo
  ];

  security.hideProcessInformation = true;
  security.sudo.enable = true;

  services.openssh.enable = true;

  # services.weechat.enable = true;

  users.users.root.hashedPassword = "$6$PS.1SD6/$kUv8wdXYH00dEvpqlC9SyX/E3Zm3HLPNmsxLwteJSQgpXDOfFZhWXkHby6hvZ.kFN2JbgXqJvwZfjOunBpcHX0";
  users.users."rok" = {
    hashedPassword = "$6$PS.1SD6/$kUv8wdXYH00dEvpqlC9SyX/E3Zm3HLPNmsxLwteJSQgpXDOfFZhWXkHby6hvZ.kFN2JbgXqJvwZfjOunBpcHX0";
    isNormalUser = true;
    uid = 1000;
    description = "Rok Garbas";
    extraGroups = [ "wheel" ] ;
    group = "users";
    home = "/home/rok";
  };

  # disable as much as possible
  hardware.pulseaudio.enable = false;
  services.printing.enable = false;
  services.xserver.enable = false;
  sound.enable = false;

  system.stateVersion = "18.09";

}
