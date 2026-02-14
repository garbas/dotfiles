{
  config,
  pkgs,
  lib,
  user,
  hostname,
  inputs,
  customVimPlugins,
  ...
}:

let
  linuxPackages = pkgs.linuxPackages_6_6;
in
{
  imports = [
    (import
      "${inputs.nixos-hardware}/lenovo/thinkpad/x220/default.nix"
    )
    inputs.home-manager.nixosModules.home-manager
    ./profiles/hyprland.nix
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = {
    inherit
      user
      inputs
      hostname
      customVimPlugins
      ;
  };
  home-manager.users.${user.username} =
    import ./../homeConfigurations/profiles/hyprland.nix;

  # Boot - ZFS
  boot.supportedFilesystems = [ "zfs" ];
  boot.kernelPackages = lib.mkForce linuxPackages;
  boot.initrd.availableKernelModules = [
    "ehci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
    "sr_mod"
    "sdhci_pci"
  ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.loader.efi.efiSysMountPoint =
    "/boot/efis/ata-INTEL_SSDSA2CW300G3_CVPR140201HJ300EGN-part1";
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.consoleMode = "auto";
  boot.zfs.devNodes = "/dev/disk/by-id";

  # Filesystems - ZFS
  fileSystems."/" = {
    device = "rpool/nixos/ROOT/default";
    fsType = "zfs";
    options = [ "zfsutil" "X-mount.mkdir" ];
  };

  fileSystems."/boot" = {
    device = "bpool/nixos/BOOT/default";
    fsType = "zfs";
    options = [ "zfsutil" "X-mount.mkdir" ];
  };

  fileSystems."/nix" = {
    device = "rpool/nixos/DATA/local/nix";
    fsType = "zfs";
    options = [ "zfsutil" "X-mount.mkdir" ];
  };

  fileSystems."/home" = {
    device = "rpool/nixos/DATA/default/home";
    fsType = "zfs";
    options = [ "zfsutil" "X-mount.mkdir" ];
  };

  fileSystems."/root" = {
    device = "rpool/nixos/DATA/default/root";
    fsType = "zfs";
    options = [ "zfsutil" "X-mount.mkdir" ];
  };

  fileSystems."/srv" = {
    device = "rpool/nixos/DATA/default/srv";
    fsType = "zfs";
    options = [ "zfsutil" "X-mount.mkdir" ];
  };

  fileSystems."/usr/local" = {
    device = "rpool/nixos/DATA/default/usr/local";
    fsType = "zfs";
    options = [ "zfsutil" "X-mount.mkdir" ];
  };

  fileSystems."/var/log" = {
    device = "rpool/nixos/DATA/default/var/log";
    fsType = "zfs";
    options = [ "zfsutil" "X-mount.mkdir" ];
  };

  fileSystems."/var/spool" = {
    device = "rpool/nixos/DATA/default/var/spool";
    fsType = "zfs";
    options = [ "zfsutil" "X-mount.mkdir" ];
  };

  fileSystems."/state" = {
    device = "rpool/nixos/DATA/default/state";
    fsType = "zfs";
    options = [ "zfsutil" "X-mount.mkdir" ];
  };

  fileSystems."/etc/nixos" = {
    device = "/state/etc/nixos";
    fsType = "none";
    options = [ "bind" ];
  };

  fileSystems."/etc/cryptkey.d" = {
    device = "/state/etc/cryptkey.d";
    fsType = "none";
    options = [ "bind" ];
  };

  fileSystems."/boot/efis/ata-INTEL_SSDSA2CW300G3_CVPR140201HJ300EGN-part1" =
    {
      device = "/dev/disk/by-uuid/F220-B691";
      fsType = "vfat";
      options = [
        "x-systemd.idle-timeout=1min"
        "x-systemd.automount"
        "noauto"
      ];
    };

  swapDevices = [
    {
      device =
        "/dev/disk/by-id/ata-INTEL_SSDSA2CW300G3_CVPR140201HJ300EGN-part4";
      randomEncryption.enable = true;
    }
  ];

  # Platform
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  nix.settings.max-jobs = lib.mkDefault 8;
  powerManagement.cpuFreqGovernor =
    lib.mkDefault "powersave";
  powerManagement.powertop.enable = true;

  # Networking
  networking.hostId = "be06d0a8";
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  # Persist state
  environment.etc."machine-id".source =
    "/state/etc/machine-id";
  environment.etc."zfs/zpool.cache".source =
    "/state/etc/zfs/zpool.cache";

  # Services
  services.fstrim.enable = true;
  services.thermald.enable = true;
  services.tlp.enable = true;
  services.zfs.autoScrub.enable = true;
  services.zfs.autoSnapshot.enable = true;
  systemd.services.zfs-mount.enable = false;

  # Lid close should NOT suspend (server use)
  services.logind.lidSwitch = "ignore";

  # Hardware
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;
  hardware.graphics.enable = true;
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault
      config.hardware.enableRedistributableFirmware;

  system.stateVersion = "22.11";
}
