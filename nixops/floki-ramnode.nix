{
  floki =
    { config, pkgs, lib, ... }:
    {
      deployment.targetEnv = "none";
      deployment.targetHost = "81.4.127.29";

      imports =
        [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
          <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
        ];

      boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" ];
      boot.kernelModules = [ "kvm-intel" ];
      boot.extraModulePackages = [ ];

      boot.loader.grub.enable = true;
      boot.loader.grub.version = 2;
      boot.loader.grub.device = "/dev/sda";

      fileSystems."/" =
        { device = "rpool/root/nixos";
          fsType = "zfs";
        };
      fileSystems."/boot" =
        { device = "/dev/sda1";
          fsType = "ext4";
        };
      fileSystems."/home" =
        { device = "rpool/home";
          fsType = "zfs";
        };

      swapDevices = [ ];

      nix.maxJobs = 2;
    };
}
