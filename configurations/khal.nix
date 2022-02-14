{ nixpkgs
, nixos-hardware
}:

{ config, pkgs, lib, ... }:

let
  linuxPackages = pkgs.linuxPackages;
  #linuxPackages = pkgs.linuxPackages_5_14;

  overlay = final: prev: {
    vaapiIntel = prev.vaapiIntel.override { enableHybridCodec = true; };
  };

in {
  imports =
    [ (import "${nixos-hardware}/dell/xps/13-7390/default.nix")
      (import ./modules.nix)
      (import ./profiles/console.nix { inherit nixpkgs; })
    ];

  boot.extraModulePackages = [
    (linuxPackages.v4l2loopback.override { inherit (linuxPackages) kernel; })
  ];
  boot.extraModprobeConfig = ''
    options kvm_intel nested=1
    options kvm_intel emulate_invalid_guest_state=0
    options kvm ignore_msrs=1
    options v4l2loopback exclusive_caps=1 video_nr=9 card_label="obs"
  '';
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelPackages = lib.mkForce linuxPackages;
  boot.kernelModules = [
    "kvm-intel"
    "v4l2loopback"
  ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.copyKernels = true;
  #boot.zfs.enableUnstable = true;

  fileSystems."/" =
    { device = "rpool/ROOT";
      fsType = "zfs";
    };

  fileSystems."/home" =
    { device = "rpool/HOME";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/ADB6-356E";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/f38786d1-369a-42e5-8962-13ce86877d98"; }
    ];

  nix.settings.max-jobs = lib.mkDefault 8;
  nix.buildMachines = [
      # tweag remote builder
      {
        hostName = "build01.tweag.io";
        maxJobs = 24;
        sshUser = "nix";
        sshKey = "/root/.ssh/id_rsa";
        system = "x86_64-linux";
        supportedFeatures = [ "benchmark" "big-parallel" "kvm" ];
      }
    ];

  nixpkgs.config.firefox.enableFoofleTalkPlugin = true;
  nixpkgs.config.pulseaudio = true;
  nixpkgs.overlays = [ overlay ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  console.keyMap = "us";
  console.font = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";

  networking.hostName = "khal";
  networking.hostId = "b0f5a1e0";
  networking.nat.enable = true;
  networking.nat.internalInterfaces = ["ve-+"];
  networking.nat.externalInterface = "wlp2s0";
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];
  networking.firewall.allowedUDPPortRanges = [ { from = 60000; to = 61000; } ];
  networking.networkmanager.enable = true;

  environment.variables.GDK_DPI_SCALE = "0.5";
  environment.variables.GDK_SCALE = "2";
  environment.variables.QT_AUTO_SCREEN_SCALE_FACTOR = "1";
  environment.systemPackages = with pkgs; [

    # email
    #notmuch
    #isync
    #afew
    #alot
    #mailcap
    #w3m
    #imapnotify
    #msmtp
    #khal
    #khard
    #vdirsyncer
    #noti

    # gui editors
    #vscode-with-extensions

    # chat
    zoom-us
    element-desktop
    signal-desktop
    discord

    # terminals
    alacritty
    kitty
    termite

    # browsers
    firefox
    chromium
    #XXXopera

    # i3 related
    rofi
    volumeicon
    xclip

    # trays / applets
    networkmanagerapplet
    pa_applet
    pasystray
    i3status-rust

    # gui tools
    pavucontrol
    transmission-gtk
    uhk-agent
    zathura
    # obs-studio with plugins
    (wrapOBS { plugins = with obs-studio-plugins; [ wlrobs ]; })
    peek

    # commonly used console utilities
    jq
    entr
    neofetch
    fzf
    ngrok
    zoxide

    # common console tools
    file
    tree
    unzip
    wget
    which

    # other console tools
    feh          # image viewer
    mpv          # video player

    # password managers
    _1password-gui
  ];

  programs.dconf.enable = true;

  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  services.blueman.enable = true;
  services.dbus.enable = true;
  services.dunst.enable = true;
  services.dunst.config = import ./dunstrc.nix { inherit (pkgs) rofi; };
  services.fprintd.enable = true;
  services.fstrim.enable = true;
  services.fwupd.enable = true;
  services.printing.drivers = with pkgs; [ hplip ];
  services.printing.enable = true;
  services.timesyncd.enable = true;
  services.udev.packages = with pkgs; [ uhk-agent ];
  services.zfs.autoScrub.enable = true;
  services.zfs.autoSnapshot.enable = true;

  services.xserver.autorun = true;
  services.xserver.dpi = 227;
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e, ctrl:nocaps";
  services.xserver.autoRepeatDelay = 200;
  services.xserver.autoRepeatInterval = 25;

  services.xserver.libinput.enable = true;
  services.xserver.libinput.touchpad.disableWhileTyping = true;
  services.xserver.libinput.touchpad.naturalScrolling = false;

  services.xserver.desktopManager.xterm.enable = false;

  services.xserver.displayManager.defaultSession = "none+i3";
  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.xorg.xrdb}/bin/xrdb -merge <<EOF
      Xcursor.theme: Adwaita
      Xcursor.size: 32
    EOF
  '';
  services.xserver.displayManager.autoLogin.user = "rok";
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.lightdm.greeter.enable = false;

  services.xserver.windowManager.i3.enable = true;

  virtualisation.libvirtd.enable = true;
  # FIXME: virtualisation.virtualbox.host.enable = true;

  sound.enable = true;

  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;

  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.package = pkgs.pkgs.pulseaudioFull;
  hardware.pulseaudio.support32Bit = true;

  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ vaapiIntel ];

  hardware.bluetooth.enable = true;
  hardware.bluetooth.package = pkgs.bluezFull;

  users.mutableUsers = false;
  users.users."root" = {
    hashedPassword = "$6$sBFfflUBZtZMD$h.EWNsmmX8iwTM7jShIvYwvS2/h7dncGTNhG.yPN1dOte1Et0TTz7HSFmzkuWjQpnBAfANYdptF3EQoUNSYwx/";
  };
  users.users."rok" = {
    hashedPassword = "$6$PS.1SD6/$kUv8wdXYH00dEvpqlC9SyX/E3Zm3HLPNmsxLwteJSQgpXDOfFZhWXkHby6hvZ.kFN2JbgXqJvwZfjOunBpcHX0";
    isNormalUser = true;
    uid = 1000;
    description = "Rok Garbas";
    extraGroups = [ "audio" "wheel" "vboxusers" "networkmanager" "docker" "libvirtd" ] ;
    group = "users";
    home = "/home/rok";
  };

  system.stateVersion = "20.09";

  fonts.fontDir.enable = true;
  fonts.enableGhostscriptFonts = true;
  fonts.fonts = with pkgs; [
    # used for terminal
    fira-code
    fira-code-symbols

    # Fonts use for icons in i3 and powerlevel10k
    nerdfonts

    # Fonts use for icons in i3status-rs
    font-awesome_5
  ];
}
