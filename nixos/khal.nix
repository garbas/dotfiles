{ config, pkgs, lib, ... }:

let
  nixpkgs-mozilla-overlay = self: super: {};
  khal-overlay = self: super: {
    neovim = import ./../../nvim-config { pkgs = super; };
    dunst = super.dunst.override { dunstify = true; };
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
in {
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
      ./../../nixos-hardware/dell/xps/13-7390/default.nix
      ./modules.nix
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

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
  nix.package = pkgs.nixFlakes;
  nix.useSandbox = true;
  nix.trustedUsers = ["@wheel"];
  nix.distributedBuilds = true;
  nix.buildMachines = [
      # tweag remote builder
      {
        hostName = "build01.tweag.io";
        maxJobs = 24;
        sshUser = "nix";
        sshKey = "/root/.ssh/id-tweag-builder";
        system = "x86_64-linux";
        supportedFeatures = [ "benchmark" "big-parallel" "kvm" ];
      }
    ];
  nix.extraOptions = ''
    experimental-features = nix-command flakes
    builders-use-substitutes = true
  '';

  nixpkgs.config.allowBroken = false;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreeRedistributable = true;
  nixpkgs.config.firefox.enableFoofleTalkPlugin = true;
  nixpkgs.config.pulseaudio = true;
  nixpkgs.overlays =
    [ nixpkgs-mozilla-overlay
      khal-overlay
    ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  console.keyMap = "us";
  console.font = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "khal";
  networking.hostId = "b0f5a1e0";
  networking.nat.enable = true;
  networking.nat.internalInterfaces = ["ve-+"];
  networking.nat.externalInterface = "wlp2s0";
  networking.extraHosts = ''
    116.203.16.150 floki floki.garbas.si
    127.0.0.1 ${config.networking.hostName}
    ::1 ${config.networking.hostName}
  '';
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];
  networking.firewall.allowedUDPPortRanges = [ { from = 60000; to = 61000; } ];
  networking.networkmanager.enable = true;

  i18n.defaultLocale = "en_US.UTF-8";

  time.timeZone = "Europe/Ljubljana";

  environment.variables.GDK_SCALE = "2";
  environment.variables.GDK_DPI_SCALE = "0.5";
  environment.variables.QT_AUTO_SCREEN_SCALE_FACTOR = "1";
  environment.variables.NIX_PATH = lib.mkForce "nixpkgs=/etc/nixos/nixpkgs-channels:nixos-config=/etc/nixos/configuration.nix";
  environment.variables.GIT_EDITOR = lib.mkForce "nvim";
  environment.variables.EDITOR = lib.mkForce "nvim";
  environment.variables.FZF_DEFAULT_COMMAND = "rg --files";

  environment.systemPackages = with pkgs; [

    # email
    notmuch
    isync
    afew
    alot
    mailcap
    w3m
    imapnotify
    msmtp
    khal
    khard
    vdirsyncer
    noti

    # editors
    neovim
    vscode

    # chat
    skype
    zoom-us
    element-desktop
    discord

    # terminals
    alacritty
    termite

    # nix tools
    nixpkgs-fmt
    niv
    direnv

    # browsers
    firefox
    chromium
    opera

    # version control
    gitAndTools.gitflow
    gitAndTools.hub
    gitAndTools.gh
    gitFull
    git-town
    git-lfs
    mercurialFull

    # i3 related
    rofi
    rofi-calc
    rofi-emoji
    rofi-file-browser
    rofi-systemd
    volumeicon
    xclip

    # trays / applets
    networkmanagerapplet
    pa_applet
    pasystray
    i3status-rust

    # gui tools
    dropbox
    keybase-gui
    obs-studio
    pavucontrol
    transmission-gtk
    uhk-agent
    zathura

    # console tools
    asciinema
    awscli
    bat
    docker_compose
    entr
    feh
    file
    fzf
    gopass
    htop
    lastpass-cli
    mpv
    ngrok
    ripgrep
    scrot
    sshuttle
    starship
    tig
    tree
    unzip
    wget
    which
    youtube-dl
  ];


  documentation.info.enable = true;

  programs.dconf.enable = true;
  programs.gnupg.agent.enable = true;
  programs.gnupg.agent.enableBrowserSocket = true;
  programs.gnupg.agent.enableSSHSupport = true;
  programs.mosh.enable = true;
  programs.mtr.enable = true;
  programs.ssh.forwardX11 = false;
  programs.zsh.autosuggestions.enable = true;
  programs.zsh.enable = true;
  programs.zsh.enableCompletion = true;
  programs.zsh.syntaxHighlighting.enable = true;
  programs.zsh.shellInit = ''
    bindkey "^[[A" history-substring-search-up
    bindkey "^[[B" history-substring-search-down
    eval "$(starship init zsh)"
    eval "$(direnv hook zsh)"
  '';
  programs.zsh.ohMyZsh.enable = true;
  programs.zsh.ohMyZsh.plugins =
    [ "git"
      "mosh"
      "vi-mode"
      "history-substring-search"
    ];

  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  services.blueman.enable = true;
  services.dbus.enable = true;
  services.dunst.enable = true;
  services.dunst.config = import ./dunstrc.nix { inherit (pkgs) rofi; };
  services.fprintd.enable = true;
  services.fstrim.enable = true;
  services.fwupd.enable = true;
  services.greenclip.enable = true;
  services.kbfs.enable = true;
  services.keybase.enable = true;
  services.locate.enable = true;
  services.openssh.enable = true;
  services.printing.drivers = with pkgs; [ ]; # XXX: hplip ];
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
  services.xserver.libinput.disableWhileTyping = true;
  services.xserver.libinput.naturalScrolling = false;

  services.xserver.desktopManager.xterm.enable = false;
  services.xserver.desktopManager.xfce.enable = true;
  services.xserver.desktopManager.xfce.noDesktop = true;
  services.xserver.desktopManager.xfce.enableXfwm = false;

  services.xserver.displayManager.defaultSession = "xfce+i3";
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

  virtualisation.docker.enable = true;
  # TODO:
  # make[4]: *** [/nix/store/7j21r60aa84gan4l9xfhsj08m1vxvbqi-linux-5.6.4-dev/lib/modules/5.6.4/source/scripts/Makefile.build:268: /build/virtualbox-6.1.4-modsrc/vboxdrv/r0drv/linux/memobj-r0drv-linux.o] Error 1
  # make[4]: *** Waiting for unfinished jobs....
  # In file included from /build/virtualbox-6.1.4-modsrc/vboxdrv/r0drv/linux/waitqueue-r0drv-linux.h:38,
  #                  from /build/virtualbox-6.1.4-modsrc/vboxdrv/r0drv/linux/semevent-r0drv-linux.c:42:
  # /build/virtualbox-6.1.4-modsrc/vboxdrv/include/iprt/time.h: In function 'RTTimeSpecGetTimeval':
  # /build/virtualbox-6.1.4-modsrc/vboxdrv/include/iprt/time.h:379:13: error: dereferencing pointer to incomplete type 'struct timeval'
  #   379 |     pTimeval->tv_sec = (time_t)i64;
  #       |             ^~
  # /build/virtualbox-6.1.4-modsrc/vboxdrv/include/iprt/time.h:379:25: error: 'time_t' undeclared (first use in this function); did you mean 'ktime_t'?
  #   379 |     pTimeval->tv_sec = (time_t)i64;
  #       |                         ^~~~~~
  #       |                         ktime_t
  # /build/virtualbox-6.1.4-modsrc/vboxdrv/include/iprt/time.h:379:25: note: each undeclared identifier is reported only once for each function it appears in
  # /build/virtualbox-6.1.4-modsrc/vboxdrv/include/iprt/time.h:379:32: error: expected ';' before 'i64'
  #   379 |     pTimeval->tv_sec = (time_t)i64;
  #       |                                ^~~
  #       |                                ;
  # /build/virtualbox-6.1.4-modsrc/vboxdrv/include/iprt/time.h: In function 'RTTimeSpecSetTimeval':
  # /build/virtualbox-6.1.4-modsrc/vboxdrv/include/iprt/time.h:393:67: error: dereferencing pointer to incomplete type 'const struct timeval'
  #   393 |     return RTTimeSpecAddMicro(RTTimeSpecSetSeconds(pTime, pTimeval->tv_sec), pTimeval->tv_usec);
  #       |                                                                   ^~
  # make[4]: *** [/nix/store/7j21r60aa84gan4l9xfhsj08m1vxvbqi-linux-5.6.4-dev/lib/modules/5.6.4/source/scripts/Makefile.build:267: /build/virtualbox-6.1.4-modsrc/vboxdrv/r0drv/linux/semevent-r0drv-linux.o] Error 1
  # In file included from /build/virtualbox-6.1.4-modsrc/vboxdrv/r0drv/linux/waitqueue-r0drv-linux.h:38,
  #                  from /build/virtualbox-6.1.4-modsrc/vboxdrv/r0drv/linux/semeventmulti-r0drv-linux.c:42:
  # /build/virtualbox-6.1.4-modsrc/vboxdrv/include/iprt/time.h: In function 'RTTimeSpecGetTimeval':
  # /build/virtualbox-6.1.4-modsrc/vboxdrv/include/iprt/time.h:379:13: error: dereferencing pointer to incomplete type 'struct timeval'
  #   379 |     pTimeval->tv_sec = (time_t)i64;
  #       |             ^~
  # /build/virtualbox-6.1.4-modsrc/vboxdrv/include/iprt/time.h:379:25: error: 'time_t' undeclared (first use in this function); did you mean 'ktime_t'?
  #   379 |     pTimeval->tv_sec = (time_t)i64;
  #       |                         ^~~~~~
  #       |                         ktime_t
  # /build/virtualbox-6.1.4-modsrc/vboxdrv/include/iprt/time.h:379:25: note: each undeclared identifier is reported only once for each function it appears in
  # /build/virtualbox-6.1.4-modsrc/vboxdrv/include/iprt/time.h:379:32: error: expected ';' before 'i64'
  #   379 |     pTimeval->tv_sec = (time_t)i64;
  #       |                                ^~~
  #       |                                ;
  # /build/virtualbox-6.1.4-modsrc/vboxdrv/include/iprt/time.h: In function 'RTTimeSpecSetTimeval':
  # /build/virtualbox-6.1.4-modsrc/vboxdrv/include/iprt/time.h:393:67: error: dereferencing pointer to incomplete type 'const struct timeval'
  #   393 |     return RTTimeSpecAddMicro(RTTimeSpecSetSeconds(pTime, pTimeval->tv_sec), pTimeval->tv_usec);
  #       |                                                                   ^~
  # make[4]: *** [/nix/store/7j21r60aa84gan4l9xfhsj08m1vxvbqi-linux-5.6.4-dev/lib/modules/5.6.4/source/scripts/Makefile.build:267: /build/virtualbox-6.1.4-modsrc/vboxdrv/r0drv/linux/semeventmulti-r0drv-linux.o] Error 1
  # make[3]: *** [/nix/store/7j21r60aa84gan4l9xfhsj08m1vxvbqi-linux-5.6.4-dev/lib/modules/5.6.4/source/Makefile:1683: /build/virtualbox-6.1.4-modsrc/vboxdrv] Error 2
  # make[2]: *** [/nix/store/7j21r60aa84gan4l9xfhsj08m1vxvbqi-linux-5.6.4-dev/lib/modules/5.6.4/source/Makefile:180: sub-make] Error 2
  # make[2]: Leaving directory '/nix/store/7j21r60aa84gan4l9xfhsj08m1vxvbqi-linux-5.6.4-dev/lib/modules/5.6.4/build'
  # make[1]: *** [/build/virtualbox-6.1.4-modsrc/vboxdrv/Makefile-footer.gmk:114: vboxdrv] Error 2
  # make[1]: Leaving directory '/build/virtualbox-6.1.4-modsrc/vboxdrv'
  # make: *** [Makefile:58: vboxdrv] Error 2
  # builder for '/nix/store/0yflxycd2kc7x28a0jjh788cjab97n6k-virtualbox-modules-6.1.4-5.6.4.drv' failed with exit code 2
  # cannot build derivation '/nix/store/w6phy8ydgbzml11yb4xy2f1s9xahnicg-kernel-modules.drv': 1 dependencies couldn't be built
  # cannot build derivation '/nix/store/588dzq7cv60xa5f4lh1bnwqx90kc0aab-linux-5.6.4-modules.drv': 1 dependencies couldn't be built
  # building '/nix/store/fxssfq5la12v6wb3zcw4ydd8nrk68vlf-vscode-1.44.1.drv'...
  # cannot build derivation '/nix/store/i5a1dmrkzv0qb2q27g0wpn4zrrcygv9k-nixos-system-khal-20.09.git.b3c3a0bd183.drv': 1 dependencies couldn't be built
  # error: build of '/nix/store/i5a1dmrkzv0qb2q27g0wpn4zrrcygv9k-nixos-system-khal-20.09.git.b3c3a0bd183.drv' failed
  #virtualisation.virtualbox.host.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;
  security.hideProcessInformation = true;

  users.defaultUserShell = pkgs.zsh;
  users.mutableUsers = false;
  users.users."root" = {
    hashedPassword = "$6$sBFfflUBZtZMD$h.EWNsmmX8iwTM7jShIvYwvS2/h7dncGTNhG.yPN1dOte1Et0TTz7HSFmzkuWjQpnBAfANYdptF3EQoUNSYwx/";
  };
  users.users."rok" = {
    hashedPassword = "$6$PS.1SD6/$kUv8wdXYH00dEvpqlC9SyX/E3Zm3HLPNmsxLwteJSQgpXDOfFZhWXkHby6hvZ.kFN2JbgXqJvwZfjOunBpcHX0";
    isNormalUser = true;
    uid = 1000;
    description = "Rok Garbas";
    extraGroups = [ "audio" "wheel" "vboxusers" "networkmanager" "docker" ] ;
    group = "users";
    home = "/home/rok";
  };

  system.stateVersion = "20.09"; # Did you read the comment?

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
    powerline-fonts
    material-icons
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    fira-code
    fira-code-symbols
  ];
}
