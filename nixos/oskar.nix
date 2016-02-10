{ pkgs, ... }:

let

  secrets = import ./oskar-secrets.nix { };
  base16Theme = "default";

  i3Packages = with pkgs; {
    inherit i3 i3lock feh xss-lock dunst pa_applet rxvt_unicode-with-plugins
      networkmanagerapplet redshift base16 dmenu;
    inherit (xorg) xrandr;
    inherit (pythonPackages) ipython alot py3status;
    inherit (gnome3) gnome_keyring;
  };
  urxvtPackages = with pkgs; { inherit xsel stdenv; };
  setxkbmapPackages = with pkgs.xorg; { inherit xinput xset setxkbmap xmodmap; };

in {

  require = [
    ./hw/lenovo-x220.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.blacklistedKernelModules = [ "snd_pcsp" "pcspkr" ];

  boot.initrd.kernelModules = [
    # rootfs, hardware specific
    "ahci"
    "aesni-intel"
    # proper console asap
    "i915"
    # filesystem
    "dm_mod"
    "dm-crypt"
    "ext4"
    "ecb"
  ];

  boot.initrd.availableKernelModules = [ "scsi_wait_scan" ];
  boot.initrd.luks.devices = [
    { name = "luksroot";
      device = "/dev/sda2";
      allowDiscards = true;
      }
  ];

  # grub 2 can boot from lvm, not sure whether version 2 is default
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  fileSystems = [
    { mountPoint = "/";
      label = "root";
      }
    { mountPoint = "/boot";
      label = "boot";
      }
    { mountPoint = "/tmp";
      device = "tmpfs";
      fsType = "tmpfs";
      options = "nosuid,nodev,relatime";
    }
  ];

  environment.systemPackages = with pkgs; (builtins.attrValues (i3Packages // urxvtPackages // setxkbmapPackages )) ++ [

    # TODO:
    base16 zsh_prezto # should be included automatically
    fasd  # should be part of vim and zsh config
    pythonPackages.afew  # set with timer

    # TODO: needed for vim's syntastic
    csslint
    ctags
    htmlTidy
    phantomjs
    pythonPackages.docutils
    pythonPackages.flake8

    # email (TODO: we need to reconfigure mail system)
    msmtp
    notmuch
    offlineimap
    w3m

    # console applications
    gitAndTools.gitflow
    gitAndTools.tig
    gitFull
    gnumake
    gnupg
    htop
    keybase
    mercurialFull
    mosh
    neovim
    ngrok
    scrot
    st  # backup terminal
    unrar
    unzip
    vifm
    wget
    which

    # gui applications
    chromium
    firefox
    mplayer
    pavucontrol
    skype
    vlc
    zathura
    VidyoDesktop

    # gnome3 theme
    gnome3.dconf
    gnome3.defaultIconTheme
    gnome3.gnome_themes_standard 

    # nix tools
    nix-prefetch-scripts
    nix-repl
    nixops
    nodePackages.npm2nix
    nox
  ];

  fonts.enableFontDir = true;
  fonts.enableGhostscriptFonts = true;
  fonts.fonts = with pkgs; [
    anonymousPro
    corefonts
    freefont_ttf
    dejavu_fonts
    ttf_bitstream_vera
    source-code-pro
    terminus_font
  ];

  nix.package = pkgs.nixUnstable;
  nix.binaryCachePublicKeys = [ "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs=" ];
  nix.trustedBinaryCaches = [ "https://hydra.nixos.org" ];
  nix.extraOptions = ''
    gc-keep-outputs = true
    gc-keep-derivations = true
    auto-optimise-store = true
    build-use-chroot = relaxed
  '';

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.packageOverrides = pkgs: import ./../pkgs { inherit pkgs; };

  nixpkgs.config.firefox.jre = false;
  nixpkgs.config.firefox.enableGoogleTalkPlugin = true;
  nixpkgs.config.firefox.enableAdobeFlash = true;

  i18n.consoleFont = "lat9w-16";
  i18n.consoleKeyMap = "us";
  i18n.defaultLocale = "en_US.utf8";

  networking.hostName = "oskar";
  networking.domain = "oskar.garbas.si";
  networking.extraHosts = ''
    89.212.67.227  home
    81.4.127.29    floki floki.garbas.si
  '';

  #networking.connman.enable = true;
  networking.networkmanager.enable = true;

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 8080 8000 24800 ];

  networking.nat.enable = true;
  networking.nat.internalInterfaces = ["ve-+"];
  networking.nat.externalInterface = "wlp3s0";

  programs.ssh.forwardX11 = false;
  programs.ssh.startAgent = true;

  programs.zsh.enable = true;
  programs.zsh.shellInit = builtins.readFile "${pkgs.zsh_prezto}/runcoms/zshenv";
  programs.zsh.loginShellInit = builtins.readFile "${pkgs.zsh_prezto}/runcoms/zprofile";
  programs.zsh.interactiveShellInit = builtins.readFile "${pkgs.zsh_prezto}/runcoms/zshrc";

  # users.mutableUsers = false;
  users.users."rok" = {
    hashedPassword = "11HncXhIWAVWo";
    isNormalUser = true;
    uid = 1000;
    description = "Rok Garbas";
    extraGroups = [ "wheel" "vboxusers" "networkmanager" "docker" ] ;
    group = "users";
    home = "/home/rok";
    shell = "/run/current-system/sw/bin/zsh";
  };

  security.setuidPrograms = [ "dumpcap" ];
  security.sudo.enable = true;
  security.pam.loginLimits = [ 
    { domain = "@audio";
      item = "rtprio";
      type = "-";
      value = "99";
      }
  ];

  virtualisation.docker.enable = true;
  virtualisation.docker.socketActivation = true;

  virtualisation.virtualbox.host.enable = true;

  services.dbus.enable = true;

  services.locate.enable = true;

  services.nixosManual.showManual = true;

  services.openssh.enable = true;

  services.printing.enable = true;
  services.printing.drivers = [ pkgs.brother-hl2030 ];

  services.prey.enable = true;
  services.prey.apiKey = secrets.prey.apiKey;
  services.prey.deviceKey = secrets.prey.deviceKey;

  services.xserver.vaapiDrivers = [ pkgs.vaapiIntel ]; 
  services.xserver.autorun = true;
  services.xserver.enable = true;
  services.xserver.exportConfiguration = true;
  services.xserver.layout = "us";

  services.xserver.desktopManager.default = "none";
  services.xserver.desktopManager.xterm.enable = false;

  services.xserver.windowManager.default = "i3";
  services.xserver.windowManager.i3.enable = true;
  services.xserver.windowManager.i3.configFile = "/tmp/i3-config";

  services.xserver.displayManager.sessionCommands = ''
    cp -f /etc/i3-config-dark /tmp/i3-config
    cp -f /etc/urxvt-themes/${base16Theme}-dark /tmp/urxvt-theme
    xrdb -merge /etc/urxvt-config
    xrdb -merge /tmp/urxvt-theme
    source /etc/setxkbmap-config
  '';

  services.xserver.displayManager.slim.defaultUser = "rok";
  services.xserver.displayManager.slim.theme = pkgs.nixos_slim_theme;

  environment.etc."Xmodmap".text = import ./../pkgs/xmodmap_config.nix {};
  environment.etc."i3-config-dark".text = import ./../pkgs/i3_config.nix (i3Packages // { inherit base16Theme; inherit (pkgs) lib; dark = true; });
  environment.etc."i3-config-light".text = import ./../pkgs/i3_config.nix (i3Packages // { inherit base16Theme; inherit (pkgs) lib; dark = false; });
  environment.etc."i3status-config".text = import ./../pkgs/i3status_config.nix { inherit base16Theme; inherit (pkgs) lib base16; };
  environment.etc."urxvt-themes/${base16Theme}-dark".text = builtins.readFile "${pkgs.base16}/xresources/base16-${base16Theme}.dark.256.xresources";
  environment.etc."urxvt-themes/${base16Theme}-light".text = builtins.readFile "${pkgs.base16}/xresources/base16-${base16Theme}.light.256.xresources";
  environment.etc."urxvt-config".text = import ./../pkgs/urxvt_config.nix urxvtPackages;
  environment.etc."setxkbmap-config".text = import ./../pkgs/setxkbmap_config.nix setxkbmapPackages;

  time.timeZone = "Europe/Berlin";

  systemd.extraConfig = ''
    DefaultCPUAccounting=true
    DefaultBlockIOAccounting=true
    DefaultMemoryAccounting=true
    DefaultTasksAccounting=true
  '';

  systemd.user.services.urxvtd = {
    enable = true;
    description = "RXVT-Unicode Daemon";
    wantedBy = [ "default.target" ];
    path = [ pkgs.rxvt_unicode-with-plugins ];
    serviceConfig = {
      ExecStart = ''
        ${pkgs.rxvt_unicode-with-plugins}/bin/urxvtd -q -o
      '';
    };
  };


}
