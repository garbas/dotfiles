# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "uhci_hcd" "ehci_pci" "ata_piix" "ahci" "usb_storage" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/ab7f4d6c-abc9-49b1-96c4-488ea92db336";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/cf453c1c-700c-4630-8085-1a2e6a1a867d";
      fsType = "ext2";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/deeba7f4-bc17-4330-859e-850a789f1679"; }
    ];

  nix.maxJobs = 2;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.firefox.jre = false;
  nixpkgs.config.firefox.enableGoogleTalkPlugin = true;
  nixpkgs.config.firefox.enableAdobeFlash = true;
  nixpkgs.config.packageOverrides = pkgs: {
    flashplayer = pkgs.lib.overrideDerivation pkgs.flashplayer (old: {
      src = pkgs.fetchurl {
        url = "https://fpdownload.adobe.com/get/flashplayer/pdc/11.2.202.554/install_flash_player_11_linux.i386.tar.gz";
        sha256 = "1a26l6lz5l6qbx4lm7266pzk0zr77h6issbnayr6df9qj99bppyz";
      };
    });
  };

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  virtualisation.virtualbox.host.enable = true;

  networking.hostName = "biedronka";

  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "Europe/Warsaw";

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
  #services.printing.drivers = [ pkgs.mfcj470dw ];

  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";
  services.xserver.displayManager.slim.enable = true;
  services.xserver.desktopManager.gnome3.enable = true;
  services.xserver.desktopManager.default = "none";
  services.xserver.desktopManager.xterm.enable = false;

  users.users.brygida = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "vboxusers" ];
    uid = 1000;
  };

  system.autoUpgrade.enable = true;
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-15.09";

}
