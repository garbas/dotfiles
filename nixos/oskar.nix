{ pkgs, ... }:

let
  secrets = import ./oskar-secrets.nix { };
in {

  require = [
    ./hw/lenovo-x220.nix
  ];

  boot = {
    initrd = {
      kernelModules = [
        # rootfs, hardware specific
        "ahci"
        "aesni-intel"

        # proper console asap
        "i915"

        "dm_mod"
        "dm-crypt"
        "ext4"
        "ecb"
      ];
      availableKernelModules = [
        "scsi_wait_scan"
      ];
      luks = {
        devices = [ {
          name = "luksroot";
          device = "/dev/sda2";
          allowDiscards = true;
          } ];
      };
    };
    kernelPackages = pkgs.linuxPackages_latest;
    blacklistedKernelModules = [ "snd_pcsp" "pcspkr" ];
    extraModprobeConfig = ''
      options sdhci debug_quirks=0x4670
      options thinkpad_acpi fan_control=1
    '';

    # grub 2 can boot from lvm, not sure whether version 2 is default
    loader.grub = {
      enable = true;
      version = 2;
      device = "/dev/sda";
    };

    # major:minor number of my swap device, fully lvm-based system
    #resumeDevice = "254:1";
  };

  fileSystems = [
    { mountPoint = "/";
      label = "root";
    } {
      mountPoint = "/boot";
      label = "boot";
    }
    { mountPoint = "/tmp";
      device = "tmpfs";
      fsType = "tmpfs";
      options = "nosuid,nodev,relatime";
    }
  ];

  environment = {
    shellInit = ''
      source ${pkgs.base16}/shell/base16-default.dark.sh
    '';
    loginShellInit = ''
      source ${pkgs.base16}/shell/base16-default.dark.sh
    '';
    interactiveShellInit = ''
      source ${pkgs.base16}/shell/base16-default.dark.sh
    '';
    systemPackages = with pkgs; [

      ## TODO: create nixos configuration for
      xlibs.xmodmap  # needed for bin/launch/keyboard

      # uncategorized
      redshift
      msmtp
      notmuch
      w3m
      offlineimap

      i3status
      dmenu2
      pythonPackages.afew
      pythonPackages.alot
      scrot
      vifm

      rxvt_unicode-with-plugins
      fasd
      st

      xsel
      gnome3.dconf
      gnome3.defaultIconTheme
      gnome3.gnome_themes_standard 
      gnome.gnome_keyring
      pavucontrol
      stdenv
      nodejs
      openvpn

      # nix tools
      nox
      nixops
      nix-repl
      nix-prefetch-scripts
      nodePackages.npm2nix

      # cmd line tools
      which
      wget
      htop
      unrar
      unzip
      pythonPackages.py3status
      mosh
      gnumake
      goaccess
      ngrok

      # version control
      #subversion
      #mercurialFull
      #bazaar
      #bazaarTools
      gitFull
      gitAndTools.tig
      gitAndTools.gitflow

      pythonFull
      keybase

      # editor and their tools
      neovim

      # needed for vim's syntastic
      phantomjs
      pythonPackages.flake8
      pythonPackages.docutils
      htmlTidy
      csslint
      ctags

      # browsers
      chromium
      firefox

      ## programs
      zathura
      skype
      mplayer
      vlc



      # --------- 
      # old stuff
      # --------- 
      #zlib
      #acpitool
      #alsaLib
      #alsaPlugins
      #alsaUtils
      #bc
      #colordiff
      #cpufrequtils
      #cryptsetup
      #ddrescue
      #file
      #gnupg
      #gnupg1
      #keychain
      #links2
      ##mailutils
      #ncftp
      #netcat
      #nmap
      #p7zip
      #parted
      #pinentry
      #powertop
      #pwgen
      #stdmanpages
      #tcpdump
      #telnet
      #units
      #bash
      ##kde410.calligra
      ##blueman
      #xfontsel
      #xlibs.xev
      #xlibs.xinput
      #xlibs.xmessage
      #lcov
    ];
  };

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
       anonymousPro
       corefonts
       freefont_ttf
       dejavu_fonts
       ttf_bitstream_vera
       source-code-pro
       terminus_font
    ];
  };

  nix = {
    package = pkgs.nixUnstable;
    binaryCachePublicKeys = [ "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs=" ];
    trustedBinaryCaches = [
        "https://hydra.nixos.org"
        "https://hydra.cryp.to"
    ];
    extraOptions = ''
        gc-keep-outputs = true
        gc-keep-derivations = true
        auto-optimise-store = true
    '';
    useChroot = false;
  };

  nixpkgs.config = {

    allowUnfree = true;

    firefox = {
     jre = false;
     enableGoogleTalkPlugin = true;
     enableAdobeFlash = true;
    };

    packageOverrides = pkgs: import ./../pkgs { inherit pkgs; };

  };

  i18n = {
    consoleFont = "lat9w-16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.utf8";
  };

  networking = {
    domain = "oskar.garbas.si";
    extraHosts = ''
        89.212.67.227  home
        81.4.127.29    floki floki.garbas.si
    '';
    # TODO: connman.enable = true;
    networkmanager.enable = true;
    firewall = {
      allowedTCPPorts = [ 80 8080 8000 24800 ];
      enable = true;
    };
    hostName = "oskar";
    nat.enable = true;
    nat.internalInterfaces = ["ve-+"];
    nat.externalInterface = "wlp3s0";
  };

  programs = {
    ssh.forwardX11 = false;
    ssh.startAgent = true;
    zsh = {
      enable = true;
      shellInit = builtins.readFile "${pkgs.zsh_prezto}/runcoms/zshenv";
      loginShellInit = builtins.readFile "${pkgs.zsh_prezto}/runcoms/zprofile";
      interactiveShellInit = builtins.readFile "${pkgs.zsh_prezto}/runcoms/zshrc";
    };
  };

  #users.mutableUsers = false;
  users.extraUsers."rok" =
    { #createUser = true;
      extraGroups = [ "wheel" "vboxusers" "networkmanager" ] ;
      group = "users";
      home = "/home/rok";
      description = "Rok Garbas";
      shell = "/run/current-system/sw/bin/zsh";
      uid = 1000;
    };

  security = {
    setuidPrograms = [ "dumpcap" ];
    sudo.enable = true;
    pam.loginLimits = [
      { domain = "@audio"; item = "rtprio"; type = "-"; value = "99"; }
    ];
  };

  virtualisation = {
    virtualbox.host.enable = true;
  };

  services = {
    dbus.enable = true;
    locate.enable = true;
    nixosManual.showManual = true;
    openssh.enable = true;
    printing.enable = true;
    thinkfan.enable = true;
    thinkfan.sensor = "/sys/class/hwmon/hwmon0/temp1_input";
    prey = {
      enable = true;
      apiKey = secrets.prey.apiKey;
      deviceKey = secrets.prey.deviceKey;
    };
    xserver = {
      vaapiDrivers = [ pkgs.vaapiIntel ]; 
      autorun = true;
      enable = true;
      exportConfiguration = true;
      layout = "us";
      windowManager.default = "i3";
      windowManager.i3 = {
        enable = true;
        configFile = pkgs.writeText "i3-config" (import ./../pkgs/i3_config.nix { inherit pkgs; });
      };
      desktopManager = {
        default = "none";
        xterm.enable = false;
      };
      displayManager.sessionCommands = ''
        xrdb -merge ${pkgs.writeText "Xresources" (import ./../pkgs/urxvt_config.nix { inherit pkgs; })}
      '';
      displayManager.slim = {
        defaultUser = "rok";
        theme = pkgs.fetchurl {
            url = "https://github.com/jagajaga/nixos-slim-theme/raw/master/nixos-slim-theme.tar.gz";
            sha256 = "0bn7m3msmwnhlmfz3x3zh29bgb8vs0l4d53m3z5jkgk9ryf03nk2";
        };
      };
    };
  };

  time.timeZone = "Europe/Berlin";

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
