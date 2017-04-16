{ config, pkgs, ... }:

let
  nixosVersion = "17.03";
in {

  imports =
    [ ./common-new.nix
    ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  system.stateVersion = nixosVersion;
  system.autoUpgrade.enable = true;
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-${nixosVersion}";

  virtualisation.virtualbox.host.enable = true;

  nixpkgs.config.allowBroken = false;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreeRedistributable = true;
  nixpkgs.config.firefox.enableAdobeFlash = true;
  nixpkgs.config.firefox.enableGoogleTalkPlugin = true;
  nixpkgs.config.firefox.jre = false;
  nixpkgs.config.zathura.useMupdf = true;
  # TODO: nixpkgs.config.packageOverrides = pkgs: (import ./../pkgs { inherit pkgs garbas_config; });

  programs.ssh.forwardX11 = true;
  programs.ssh.startAgent = true;

  networking.networkmanager.enable = true;

  fonts.enableFontDir = true;
  fonts.enableGhostscriptFonts = true;
  fonts.fonts = with pkgs; [
    anonymousPro
    corefonts
    dejavu_fonts
    freefont_ttf
    liberation_ttf
    source-code-pro
    terminus_font
    ttf_bitstream_vera
  ];

  services.nixosManual.showManual = true;
  services.openssh.enable = true;
  services.printing.enable = true;
  services.xserver.desktopManager.default = "gnome3";
  services.xserver.desktopManager.gnome3.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.xterm.enable = false;
  services.xserver.autorun = true;
  services.xserver.enable = true;

  systemd.extraConfig = ''
    DefaultCPUAccounting=true
    DefaultBlockIOAccounting=true
    DefaultMemoryAccounting=true
    DefaultTasksAccounting=true
  '';
}
