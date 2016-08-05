{ pkgs, config, ... }:

{
  imports = [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix> ];

  boot.extraModulePackages = [
    config.boot.kernelPackages.tp_smapi
  ];
  boot.extraModprobeConfig = ''
    options snd_hda_intel index=1,0
    options thinkpad_acpi fan_control=1 force-load=1
  '';
  boot.kernelModules = [ "kvm-intel" ];

  hardware.trackpoint = {
    enable = true;
    sensitivity = 220;
    speed = 0;
    emulateWheel = true;
  };

  hardware.bluetooth.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
  hardware.opengl.extraPackages = [ pkgs.vaapiIntel ];

  services.acpid.enable = true;
  services.thinkfan.enable = true;
  services.thinkfan.levels = ''
    (0, 0, 45)
    (1, 40, 60)
    (2, 45, 65)
    (3, 50, 75)
    (4, 55, 80)
    (5, 60, 85)
    (7, 65, 32767)
  '';
}
