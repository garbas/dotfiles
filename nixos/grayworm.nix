# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

let

  # TODO: pin external repos bellow
  # TODO: until https://github.com/NixOS/nixos-hardware/pull/60 gets merged
  # nixos-hardware = builtins.fetchTarball https://github.com/NixOS/nixos-hardware/archive/master.tar.gz;
  nixos-hardware = builtins.fetchTarball https://github.com/azazel75/nixos-hardware/archive/master.tar.gz;
  nixpkgs-mozilla = builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz;

in

{
  imports =
    [ "${nixos-hardware}/lenovo/thinkpad/x1/6th-gen/default.nix"
      <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # make suspend work on gen6
  boot.kernelParams = [
    "mem_sleep_default=deep"
  ];
  boot.initrd.prepend = [
    "${./grayworm_acpi_override}"
  ];

  fileSystems."/" =
    { device = "rpool/ROOT/NIXOS";
      encrypted = {
        enable = true;
        blkDev = "/dev/disk/by-partlabel/cryptroot";
        label = "encrypted_root";
      };
      fsType = "zfs";
    };

  fileSystems."/home" =
    { device = "rpool/HOME";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/A95E-D517";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/zd0"; }
    ];

  nix.package = pkgs.nixUnstable;
  nix.maxJobs = lib.mkDefault 8;
  nix.useSandbox = true;
  nix.trustedBinaryCaches = [ "https://hydra.nixos.org" ];
  nix.binaryCachePublicKeys = [
    "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
  ];
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.devNodes = "/dev/mapper";
  boot.zfs.forceImportAll = true;
  boot.zfs.forceImportRoot = true;

  nixpkgs.config.allowBroken = false;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreeRedistributable = true;
  nixpkgs.config.firefox.enableGoogleTalkPlugin = true;
  nixpkgs.config.pulseaudio = true;

  nixpkgs.overlays = [
    (import nixpkgs-mozilla)
  ];

  networking.hostId = "4214f894";
  networking.hostName = "grayworm"; # Define your hostname.

  networking.nat.enable = true;
  networking.nat.internalInterfaces = ["ve-+"];
  networking.nat.externalInterface = "wlp3s0";

  networking.extraHosts = ''
    81.4.127.29 floki floki.garbas.si
    127.0.0.1 ${config.networking.hostName}
    ::1 ${config.networking.hostName}
  '';

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];
  networking.firewall.allowedUDPPortRanges = [ { from = 60000; to = 61000; } ];

  networking.networkmanager.enable = true;

  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "Europe/Berlin";

  environment.variables.NIX_PATH = lib.mkForce "nixpkgs=/etc/nixos/nixpkgs-channels:nixos-config=/etc/nixos/configuration.nix";
  environment.variables.GIT_EDITOR = lib.mkForce "emacseditor";
  environment.variables.EDITOR = lib.mkForce "emacseditor";
  environment.shellAliases =
    { dotfiles = "git --git-dir=$HOME/.dotfiles --work-tree=$HOME";
    }
    ;

  environment.systemPackages = with pkgs; [
    VidyoDesktop
    alacritty
    asciinema
    docker_compose
    gitAndTools.gitflow
    gitAndTools.hub
    gitFull
    gnome3.dconf
    gnome3.defaultIconTheme
    gnome3.gnome_themes_standard
    gnupg
    htop
    i3status
    ispell
    iw
    keybase
    latest.firefox-nightly-bin
    mercurialFull
    mpv
    networkmanagerapplet
    ngrok
    obs-studio
    pa_applet
    pass
    pasystray
    pavucontrol
    pgadmin
    pythonPackages.Flootty
    pythonPackages.py3status
    rofi
    rofi-menugen
    rofi-pass
    spotify
    sshuttle
    tig
    tree
    vim
    volumeicon
    wget
    which
    xclip
    xlibs.xbacklight
    xlibs.xbacklight
    xlibs.xcursorthemes
    xlibs.xev
    xlibs.xmodmap
    xlibs.xset
    xsel
    youtube-dl
    zathura
  ];

  systemd.extraConfig = ''
    DefaultCPUAccounting=true
    DefaultBlockIOAccounting=true
    DefaultMemoryAccounting=true
    DefaultTasksAccounting=true
  '';

  programs.ssh.forwardX11 = false;
  programs.gnupg.agent.enable = true;
  programs.gnupg.agent.enableSSHSupport = true;
  programs.gnupg.agent.enableBrowserSocket = true;
  documentation.info.enable = true;
  programs.mosh.enable = true;
  programs.zsh.enable = true;
  programs.zsh.autosuggestions.enable = true;
  programs.zsh.enableCompletion = true;
  programs.zsh.ohMyZsh.enable = true;
  programs.zsh.ohMyZsh.plugins =
    [ "git"
      "mosh"
      "pass"
      "vi-mode"
    ];
  programs.zsh.ohMyZsh.theme = "avit";

  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";

  services.printing.enable = true;
  services.printing.drivers = with pkgs; [
    hplip
  ];

  sound.enable = true;

  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
  hardware.pulseaudio.extraConfig = ''
    load-module module-switch-on-connect
  '';

  hardware.opengl = {
    driSupport = true;
    driSupport32Bit = true;
  };

  services.xserver.autorun = true;
  services.xserver.enable = true;
  services.xserver.exportConfiguration = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e, ctrl:nocaps";
  services.xserver.autoRepeatDelay = 200;
  services.xserver.autoRepeatInterval = 50;
  services.xserver.libinput.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.windowManager.i3.enable = true;
  services.xserver.desktopManager.default = "none";
  services.xserver.desktopManager.xterm.enable = false;

  services.dbus.enable = true;
  services.locate.enable = true;
  security.sudo.enable = true;

  users.defaultUserShell = pkgs.zsh;
  users.mutableUsers = false;
  users.users."rok" = {
    hashedPassword = "$6$PS.1SD6/$kUv8wdXYH00dEvpqlC9SyX/E3Zm3HLPNmsxLwteJSQgpXDOfFZhWXkHby6hvZ.kFN2JbgXqJvwZfjOunBpcHX0";
    isNormalUser = true;
    uid = 1000;
    description = "Rok Garbas";
    extraGroups = [ "audio" "wheel" "vboxusers" "networkmanager" "docker" ] ;
    group = "users";
    home = "/home/rok";
  };

  virtualisation.docker.enable = true;
  virtualisation.virtualbox.host.enable = true;

  system.nixos.stateVersion = "18.03"; # Did you read the comment?

  services.emacs.enable = true;
  services.emacs.defaultEditor = true;
  services.emacs.package = pkgs.emacs;

  services.zfs.autoScrub.enable = true;
  services.zfs.autoSnapshot.enable = true;

  services.syncthing.enable = true;
  services.syncthing.openDefaultPorts = true;
  services.syncthing.user = "rok";
  services.syncthing.dataDir = "/home/rok/.local/syncthing";

  #services.autorandr.defaultTarget = "mobile";
  #services.autorandr.enable = true;

  fonts.enableFontDir = true;
  fonts.enableGhostscriptFonts = true;
  fonts.fonts = with pkgs; [
    anonymousPro
    dejavu_fonts
    freefont_ttf
    liberation_ttf
    source-code-pro
    terminus_font
    font-awesome_5
    material-icons
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    #noto-fonts-extra
  ];
}
