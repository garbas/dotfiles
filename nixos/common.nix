{ i3_tray_output }:

{ pkgs, config, ... }:
let
  garbas_config = import ../config { inherit i3_tray_output pkgs; };
in {

  boot.blacklistedKernelModules = [ "snd_pcsp" "pcspkr" ];
  boot.kernelModules = [ "intel_agp" "i915" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.zfs.enableUnstable = true;

  #boot.kernelPackages = pkgs.linuxPackages_4_8;
  #boot.kernelPackages = pkgs.linuxPackages_4_4;

  environment.systemPackages = with pkgs; [

    # gui apps
    firefox-beta-bin
    chromium
    vlc
    tdesktop

    # nix tools
    nix-prefetch-scripts
    nix-repl
    nixops
    nodePackages.node2nix
    nox

  ];

  i18n.consoleFont = "Lat2-Terminus16";
  i18n.consoleKeyMap = "us";
  i18n.defaultLocale = "en_US.UTF-8";

  networking.networkmanager.enable = true;

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 8080 8000 24800 ];

  networking.nat.enable = true;
  networking.nat.internalInterfaces = ["ve-+"];
  networking.nat.externalInterface = "wlp3s0";

  nix.package = pkgs.nixUnstable;
  nix.binaryCachePublicKeys = [
    "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
  ];
  nix.useSandbox = true;
  nix.trustedBinaryCaches = [ "https://hydra.nixos.org" ];
  nix.extraOptions = ''
    gc-keep-outputs = true
    gc-keep-derivations = true
    auto-optimise-store = true
  '';

  nixpkgs.config.allowBroken = false;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreeRedistributable = true;
  nixpkgs.config.packageOverrides = pkgs: (import ./../pkgs { inherit pkgs garbas_config; });
  nixpkgs.config.firefox.enableAdobeFlash = true;
  nixpkgs.config.firefox.enableGoogleTalkPlugin = true;
  nixpkgs.config.firefox.jre = false;
  nixpkgs.config.zathura.useMupdf = true;


  programs.ssh.forwardX11 = false;
  programs.ssh.startAgent = true;

  security.sudo.enable = true;

  services.dbus.enable = true;
  services.locate.enable = true;
  services.nixosManual.showManual = true;
  services.openssh.enable = true;

  services.printing.enable = true;
  services.printing.drivers = [ pkgs.brother-hl2030 ];

  services.xserver.autorun = true;
  services.xserver.enable = true;
  services.xserver.exportConfiguration = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";

  services.xserver.desktopManager.xterm.enable = false;

  systemd.extraConfig = ''
    DefaultCPUAccounting=true
    DefaultBlockIOAccounting=true
    DefaultMemoryAccounting=true
    DefaultTasksAccounting=true
  '';

  users.mutableUsers = false;
  #users.users."root".shell = "/run/current-system/sw/bin/zsh";

  time.timeZone = "Europe/Berlin";

  virtualisation.virtualbox.host.enable = true;

}
