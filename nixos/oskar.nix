{ pkgs, ... }:

let

  secrets = import ./oskar-secrets.nix { };

  i3Packages = with pkgs; {
    inherit i3 i3lock feh xss-lock dunst pa_applet rxvt_unicode-with-plugins
      networkmanagerapplet redshift;
    inherit (xorg) xrandr;
    inherit (pythonPackages) ipython alot;
    inherit (gnome3) gnome_keyring;
  };
  urxvtPackages = with pkgs; { inherit xsel; };
  setxkbmapPackages = with pkgs.xorg; { inherit xinput xset setxkbmap xmodmap; };

in {

  require = [
    ./hw/lenovo-x220.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.blacklistedKernelModules = [ "snd_pcsp" "pcspkr" ];
  boot.extraModprobeConfig = ''
      options sdhci debug_quirks=0x4670
      options thinkpad_acpi fan_control=1
    '';

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

  environment.shellInit = "source ${pkgs.base16}/shell/base16-default.dark.sh";
  environment.loginShellInit = "source ${pkgs.base16}/shell/base16-default.dark.sh";
  environment.interactiveShellInit = "source ${pkgs.base16}/shell/base16-default.dark.sh";

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

    # window manager
    dmenu2
    i3status
    pythonPackages.py3status

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

  # TODO: connman.enable = true;
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

  # TODO: users.mutableUsers = false;
  users.extraUsers."rok" = {
    extraGroups = [ "wheel" "vboxusers" "networkmanager" ] ;
    group = "users";
    home = "/home/rok";
    description = "Rok Garbas";
    shell = "/run/current-system/sw/bin/zsh";
    uid = 1000;
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
  services.xserver.windowManager.i3.configFile =
    pkgs.writeText "i3-config" ( import ./../pkgs/i3_config.nix i3Packages );

  services.xserver.displayManager.sessionCommands = ''
      xrdb -merge ${
        pkgs.writeText "Xresources"
          ( import ./../pkgs/urxvt_config.nix urxvtPackages )}
    '';

  services.xserver.displayManager.slim.defaultUser = "rok";
  services.xserver.displayManager.slim.theme = pkgs.nixos_slim_theme;

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

  environment.etc."Xmodmap".text = import ./../pkgs/xmodmap_config.nix {};
  systemd.services.display-manager.postStart =
    (import ./../pkgs/setxkbmap_config.nix setxkbmapPackages);

}
