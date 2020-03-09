{ config, pkgs, lib, ... }:

let
  nixpkgs-mozilla-overlay = self: super: {};
  khal-overlay = self: super: {
    neovim = import ./../../nvim-config { inherit pkgs; };
    dunst = super.dunst.override { dunstify = true; };
  };
in {
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
      ./modules.nix
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
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
  nix.extraOptions = ''
    experimental-features = nix-command flakes
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

  environment.variables = {
    GDK_SCALE = "2";
    GDK_DPI_SCALE = "0.5";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
  };
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

    # editors
    neovim
    vscode

    # chat
    skype
    zoom-us

    # terminals
    alacritty
    termite
    hyper

    # browsers
    firefox
    chromium
    opera

    # version control
    gitAndTools.gitflow
    gitAndTools.hub
    gitFull
    mercurialFull

    # i3 related
    gnome3.adwaita-icon-theme
    gnome3.dconf
    gnome3.defaultIconTheme
    hicolor-icon-theme
    rofi
    rofi-menugen
    volumeicon
    xclip

    # trays / applets
    networkmanagerapplet
    pa_applet
    pasystray
    i3status-rust

    # gui tools
    obs-studio
    pavucontrol
    zathura
    keybase-gui

    # console tools
    asciinema
    docker_compose
    entr
    file
    fzf
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

  programs.ssh.forwardX11 = false;
  programs.mtr.enable = true;
  programs.gnupg.agent.enable = true;
  programs.gnupg.agent.enableSSHSupport = true;
  programs.gnupg.agent.enableBrowserSocket = true;
  programs.mosh.enable = true;
  programs.zsh.enable = true;
  programs.zsh.autosuggestions.enable = true;
  programs.zsh.enableCompletion = true;
  programs.zsh.syntaxHighlighting.enable = true;
  programs.zsh.shellInit = ''
    bindkey "^[[A" history-substring-search-up
    bindkey "^[[B" history-substring-search-down
    eval "$(starship init zsh)"
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
  services.greenclip.enable = true;
  services.kbfs.enable = true;
  services.keybase.enable = true;
  services.locate.enable = true;
  services.openssh.enable = true;
  services.printing.drivers = with pkgs; [ hplip ];
  services.printing.enable = true;
  services.timesyncd.enable = true;
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

  services.xserver.displayManager.defaultSession = "none+i3";
  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.xorg.xrdb}/bin/xrdb -merge <<EOF
      Xcursor.theme: Adwaita
      Xcursor.size: 32
    EOF
    
  '';
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.lightdm.greeter.enable = false;
  services.xserver.displayManager.lightdm.autoLogin.enable = true;
  services.xserver.displayManager.lightdm.autoLogin.user = "rok";

  services.xserver.windowManager.i3.enable = true;

  virtualisation.docker.enable = true;
  virtualisation.virtualbox.host.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.u2f.enable = true;

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;
  security.hideProcessInformation = true;

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
