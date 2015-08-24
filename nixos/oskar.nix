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
    systemPackages = with pkgs; [

      # TODO: create nixos configuration for
      xlibs.xmodmap  # needed for bin/launch/keyboard

      # uncategorized
      redshift
      msmtp
      notmuch
      w3m
      offlineimap
      pythonPackages.alot
      pythonPackages.afew
      dunst
      libnotify
      xss-lock
      i3lock
      i3status
      dmenu2
      scrot
      vifm
      rxvt_unicode
      fasd
      xsel
      pa_applet
      networkmanagerapplet
      gnome3.dconf
      gnome3.defaultIconTheme
      gnome3.gnome_themes_standard 
      gnome.gnome_keyring
      pavucontrol
      stdenv
      pypi2nix
      nodejs
      openvpn
      vimPlugins.YouCompleteMe
      silver-searcher


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
      pythonPackages.ipython
      pythonPackages.py3status
      mosh
      gnumake

      #goaccess
      #ngrok

      # version control
      subversion
      mercurialFull
      bazaar
      bazaarTools
      gitFull
      gitAndTools.tig

      pythonFull
      keybase

      # editor and their tools
      neovim

      ## needed for vim's syntastic
      #phantomjs
      #pythonPackages.flake8
      #pythonPackages.docutils
      #htmlTidy
      #csslint
      ##xmllint
      ##zptlint
      #ctags

      # browsers
      chromiumBeta
      firefoxWrapper

      # programs
      #gitAndTools.gitAnnex
      zathura
      skype
      #mplayer2
      #vlc
      gftp
      #calibre
      gimp_2_8
      inkscape
      #libreoffice

      # hacking tools
      #wireshark
      aircrackng


      # --------- 
      # old stuff
      # --------- 

      zlib
      acpitool
      alsaLib
      alsaPlugins
      alsaUtils
      bc
      colordiff
      cpufrequtils
      cryptsetup
      ddrescue
      file
      gnupg
      gnupg1
      keychain
      links2
      #mailutils
      ncftp
      netcat
      nmap
      p7zip
      parted
      pinentry
      powertop
      pwgen
      stdmanpages
      tcpdump
      telnet
      units
      bash
      #kde410.calligra
      #blueman
      xfontsel
      xlibs.xev
      xlibs.xinput
      xlibs.xmessage
      pythonPackages.turses
      newsbeuter
      lcov
    ];
  };

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = [
       pkgs.anonymousPro
       pkgs.corefonts
       pkgs.freefont_ttf
       pkgs.dejavu_fonts
       pkgs.ttf_bitstream_vera
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
    useChroot = true;
  };


  nixpkgs.config = {
    allowUnfree = true;

    firefox = {
     jre = false;
     enableGoogleTalkPlugin = true;
     enableAdobeFlash = true;
    };

    chromium = {
     jre = false;
     enableGoogleTalkPlugin = true;
     enableAdobeFlash = true;
    };
    rxvt_unicode = {
      perlBindings = true;
    };

    packageOverrides = pkgs: import ./../pkgs { inherit pkgs; };

  };

  i18n = {
    consoleFont = "lat9w-16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.utf8";
  };

  #virtualisation.libvirtd.enable = true;

  networking = {
    domain = "oskar.garbas.si";
    extraHosts = ''
        89.212.67.227  home
        81.4.127.29    floki floki.garbas.si
    '';
    #connman.enable = true;
    networkmanager.enable = true;
    firewall = {
      allowedTCPPorts = [ 80 8080 8000 24800 ];
      enable = true;
    };
    hostName = "oskar";
  };

  programs = {
    ssh.forwardX11 = false;
    ssh.startAgent = true;
    bash.enableCompletion = true;
    zsh.enable = true;
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

  virtualisation.virtualbox.host.enable = true;

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
      windowManager.i3.enable = true;
      windowManager.default = "i3";
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
}
