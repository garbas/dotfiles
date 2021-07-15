{ nixpkgs 
, nixos-hardware
, onlyoffice
}:

{ config, pkgs, lib, ... }:

let
  nixpkgs-mozilla-overlay = self: super: {};

  custom-overlay-old = self: super: {

    neofetch = super.neofetch.overrideAttrs (old: {
      patches = (self.lib.optionals (builtins.hasAttr "patches" old) old.patches) ++ [
        (self.fetchurl { 
          url = "https://github.com/dylanaraps/neofetch/pull/1134.patch";
          #sha256 = "sha256-flryIeD1P1tUPgfxgzaGLxveJUyzogCVuQHxII+DjYw=";
          sha256 = "sha256-XzYhKdwLO5ANf/ndLBomrQbi8p4fu1zlqimiZYhuItA=";
        })
      ];
    });

    uhk-agent =
      let
        version = "1.2.12";
        #version = "1.4.3";
        image = self.stdenv.mkDerivation {
          name = "uhk-agent-image";
          src = self.fetchurl {
            url = "https://github.com/UltimateHackingKeyboard/agent/releases/download/v${version}/UHK.Agent-${version}-linux-x86_64.AppImage";
            sha256 = "1gr3q37ldixcqbwpxchhldlfjf7wcygxvnv6ff9nl7l8gxm732l6";
            #sha256 = "sha256-zbQyouXC8qebYeYbyyl7fulYe4rRens5j+LvW7y8bqI=";
          };
          buildCommand = ''
            mkdir -p $out
            cp $src $out/appimage
            chmod ugo+rx $out/appimage
          '';
        };
      in self.runCommand "uhk-agent" {} ''
        mkdir -p $out/bin $out/etc/udev/rules.d 
        echo "${self.appimage-run}/bin/appimage-run ${image}/appimage" > $out/bin/uhk-agent
        chmod +x $out/bin/uhk-agent
        cat > $out/etc/udev/rules.d/50-uhk60.rules <<EOF
        # Ultimate Hacking Keyboard rules
        # These are the udev rules for accessing the USB interfaces of the UHK as non-root users.
        # Copy this file to /etc/udev/rules.d and physically reconnect the UHK afterwards.
        SUBSYSTEM=="input", GROUP="input", MODE="0666"
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="612[0-7]", MODE:="0666", GROUP="plugdev"
        KERNEL=="hidraw*", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="612[0-7]", MODE="0666", GROUP="plugdev"
        EOF
      '';
  };

  linuxPackages = pkgs.linuxPackages_latest;

in {
  imports =
    [ "${nixos-hardware}/dell/xps/13-7390/default.nix"
      ./modules.nix
      ./profiles/console.nix
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
  boot.zfs.enableUnstable = true;

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

  nix.maxJobs = lib.mkDefault 8;
  nix.buildMachines = [
      # tweag remote builder
      #{
      #  hostName = "build01.tweag.io";
      #  maxJobs = 24;
      #  sshUser = "nix";
      #  sshKey = "/root/.ssh/id-tweag-builder";
      #  system = "x86_64-linux";
      #  supportedFeatures = [ "benchmark" "big-parallel" "kvm" ];
      #}
    ];

  nixpkgs.config.firefox.enableFoofleTalkPlugin = true;
  nixpkgs.config.pulseaudio = true;
  nixpkgs.overlays =
    [ nixpkgs-mozilla-overlay
      custom-overlay-old
    ];

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
    vscode-with-extensions

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
    obs-studio 
    obs-wlrobs
    obs-v4l2sink
    peek
    onlyoffice

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
    anonymousPro
    dejavu_fonts
    fira-code
    fira-code-symbols
    font-awesome_5
    freefont_ttf
    liberation_ttf
    material-icons
    meslo-lgs-nf
    nerdfonts
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    powerline-fonts
    source-code-pro
    terminus_font
  ];
}
