# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "uhci_hcd" "ehci_pci" "ahci" "firewire_ohci" "usb_storage" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/5d1a27d9-4359-4cfd-a349-53cc065048be";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/63fbb2ec-f6a8-44e8-87c4-707691b21269";
      fsType = "ext2";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/bf6879bd-158f-4e40-8550-2a5fb8a0d1b7"; }
    ];

  nix.maxJobs = 2;

  nixpkgs.config.allowUnfree = true;
  #nixpkgs.config.firefox.jre = false;
  #nixpkgs.config.firefox.enableGoogleTalkPlugin = true;
  #nixpkgs.config.firefox.enableAdobeFlash = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  virtualisation.virtualbox.host.enable = true;

  networking.hostName = "zabka";

  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "Europe/Berlin";

  environment.systemPackages = with pkgs; [
    firefox-wrapper
    skype
    libreoffice
    neovim
    gitAndTools.git
    gitAndTools.tig
    htop
  ];

  
  services.nixosManual.showManual = true;
  services.openssh.enable = true;
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.mfcj470dw ];

  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";
  services.xserver.displayManager.slim.enable = true;
  services.xserver.desktopManager.gnome3.enable = true;
  services.xserver.desktopManager.default = "none";
  services.xserver.desktopManager.xterm.enable = false;

  users.users.marta = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "vboxusers" ];
    uid = 1000;
  };

  system.autoUpgrade.enable = true;
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-unstable";

}
