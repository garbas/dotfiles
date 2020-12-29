nixpkgs: nixos-hardware: { config, pkgs, lib, ... }:

let
  nixpkgs-mozilla-overlay = self: super: {};

  custom-overlay = import ./../pkgs/overlay.nix;

  custom-overlay-old = self: super: {

    dunst = super.dunst.override { dunstify = true; };

    neofetch = super.neofetch.overrideAttrs (old: {
      patches = (self.lib.optionals (builtins.hasAttr "patches" old) old.patches) ++ [
        (self.fetchurl { 
          url = "https://github.com/dylanaraps/neofetch/pull/1134.patch";
          sha256 = "sha256-flryIeD1P1tUPgfxgzaGLxveJUyzogCVuQHxII+DjYw=";
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
in {
  imports =
    #[ "<nixpkgs/nixos/modules/installer/scan/not-detected.nix>"
    #  ./../../nixos-hardware/dell/xps/13-7390/default.nix
    #  ./modules.nix
    [ "${nixpkgs}/nixos/modules/installer/scan/not-detected.nix"
      "${nixos-hardware}/dell/xps/13-7390/default.nix"
      ./modules.nix
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [
    "kvm-intel"
    "v4l2loopback"
  ];
  boot.extraModulePackages = [
    (pkgs.linuxPackages.v4l2loopback.override { inherit (pkgs.linuxPackages_latest) kernel; })
  ];
  boot.extraModprobeConfig = ''
    options kvm_intel nested=1
    options kvm_intel emulate_invalid_guest_state=0
    options kvm ignore_msrs=1
    options v4l2loopback exclusive_caps=1 video_nr=9 card_label="obs"
  '';

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
  nix.trustedUsers = ["@wheel" "rok"];
  nix.distributedBuilds = true;
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
  nix.extraOptions = ''
    experimental-features = nix-command flakes
    builders-use-substitutes = true
  '';
  nix.registry.nixpkgs.flake = nixpkgs;

  nixpkgs.config.allowBroken = false;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreeRedistributable = true;
  nixpkgs.config.firefox.enableFoofleTalkPlugin = true;
  nixpkgs.config.pulseaudio = true;
  nixpkgs.overlays =
    [ nixpkgs-mozilla-overlay
      custom-overlay-old
      custom-overlay
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

  environment.shellAliases =
  { grep = "rg";
    ls = "exa";
    find = "fd";
    du = "dust";
    ps = "procs";
    cat = "bat";
  };
  environment.variables.GDK_SCALE = "2";
  environment.variables.GDK_DPI_SCALE = "0.5";
  environment.variables.QT_AUTO_SCREEN_SCALE_FACTOR = "1";
  environment.variables.NIX_PATH = lib.mkForce "nixpkgs=/etc/nixos/nixpkgs-channels:nixos-config=/etc/nixos/configuration.nix";
  environment.variables.GIT_EDITOR = lib.mkForce "nvim";
  environment.variables.EDITOR = lib.mkForce "nvim";
  environment.variables.FZF_DEFAULT_COMMAND = "rg --files";

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

    # devops / cloud
    minikube
    kubectl
    terraform

    # editors
    neovim
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions;
        [ bbenoist.Nix
          ms-python.python
          ms-azuretools.vscode-docker
          ms-vscode.cpptools
        ];
    })

    # chat
    zoom-us
    element-desktop
    discord

    # terminals
    #alacritty
    termite

    # nix tools
    nixpkgs-fmt
    nixpkgs-review
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
    tig

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

    # improved console utilities
    bat            # cat
    ripgrep        # grep
    exa            # ls
    fd             # find
    procs          # ps
    sd             # sed
    dust           # du

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
    asciinema
    tokei        # show statistics about your code
    hyperfine    # benchmarking tool
    awscli2
    docker_compose
    feh
    htop
    mpv
    scrot
    sshuttle
    youtube-dl

    # password managers
    gopass
    lastpass-cli
    _1password
    _1password-gui

    # 
    starship
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
    #bindkey "^[[A" history-substring-search-up
    #bindkey "^[[B" history-substring-search-down
    eval "$(starship init zsh)"
    eval "$(direnv hook zsh)"
    eval "$(zoxide init zsh)"
  '';
  #programs.zsh.ohMyZsh.enable = true;
  #programs.zsh.ohMyZsh.plugins =
  #  [ "git"
  #    "mosh"
  #    "fzf"
  #    "vi-mode"
  #    "history-substring-search"
  #  ];

  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  services.blueman.enable = true;
  services.dbus.enable = true;
  services.dunst.enable = true;
  services.dunst.config = import ./dunstrc.nix { inherit (pkgs) rofi; };
  services.fprintd.enable = true;
  services.fstrim.enable = true;
  services.fwupd.enable = true;
  services.locate.enable = true;
  services.openssh.enable = true;
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

  virtualisation.libvirtd.enable = true;
  virtualisation.docker.enable = true;
  virtualisation.virtualbox.host.enable = true;

  sound.enable = true;

  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.package = pkgs.pkgs.pulseaudioFull;
  hardware.pulseaudio.support32Bit = true;

  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;


  hardware.bluetooth.enable = true;
  hardware.bluetooth.package = pkgs.bluezFull;


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
    extraGroups = [ "audio" "wheel" "vboxusers" "networkmanager" "docker" "libvirtd" ] ;
    group = "users";
    home = "/home/rok";
  };

  system.stateVersion = "20.09"; # Did you read the comment?

  fonts.fontDir.enable = true;
  fonts.enableGhostscriptFonts = true;
  fonts.fonts = with pkgs; [
    anonymousPro
    dejavu_fonts
    freefont_ttf
    liberation_ttf
    source-code-pro
    terminus_font
    font-awesome_5
    nerdfonts
    powerline-fonts
    material-icons
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    fira-code
    fira-code-symbols
  ];
}
