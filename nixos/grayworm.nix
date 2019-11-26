# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

let

  # TODO: pin external repos bellow
  # nixos-hardware = builtins.fetchTarball https://github.com/NixOS/nixos-hardware/archive/master.tar.gz;
  # nixpkgs-mozilla = builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz;
  nixos-hardware = ./../../nixos/nixos-hardware;
  nixpkgs-mozilla = ./../../nixos/nixpkgs-mozilla;

  custom_pkgs = self: super: {

    # TODO: also try https://github.com/sindresorhus/pure
    spaceship-prompt = self.stdenv.mkDerivation {
      name = "spaceship-prompt";
      src = self.fetchFromGitHub {
        owner = "denysdovhan";
        repo = "spaceship-prompt";
        rev = "c092d092854dce5eaa77426bc9a76e6774558c0a";
        sha256 = "1cmdvhjlbal10jpf8iikad88v7c44y38szvnx7ab8km4sf25sqj6";
      };
      installPhase = ''
        mkdir $out
        cp -R ./ $out/
      '';
    };

    oh-my-zsh = super.oh-my-zsh.overrideDerivation (old: {
      name = "oh-my-zsh-2018-11-27";
      src = self.fetchFromGitHub {
        owner = "robbyrussell";
        repo = "oh-my-zsh";
        rev = "2614b7ecdfe8b8f0cbeafffefb5925196f4011d4";
        sha256 = "0yfk0x7xj640xn0klyggrncvmmm3b44ldfxfrr4mcixb1scfv5lb";
      };
      phases = "${old.phases} postInstall";
      postInstall = ''
        chmod +w $out/share/oh-my-zsh/themes
        ln -s ${self.spaceship-prompt}/spaceship.zsh-theme $out/share/oh-my-zsh/themes/spaceship.zsh-theme
      '';
    });

    alacritty = self.stdenv.mkDerivation {
      name = "alacritty-${self.lib.getVersion super.alacritty}";
      buildCommand = let bin = "${super.alacritty}/bin/alacritty"; in ''
        if [ ! -x "${bin}" ];
        then
            echo "cannot find executable file \`${bin}'"
            exit 1
        fi
        mkdir -p $out/bin
        ln -s ${bin} $out/bin/alacritty
        wrapProgram $out/bin/alacritty --set WINIT_HIDPI_FACTOR 1.0
      '';
      buildInputs = [ self.makeWrapper ];
      passthru = { unwrapped = super.alacritty; };
    };

    uhk-agent =
      let
        version = "1.2.12";
        image = self.stdenv.mkDerivation {
          name = "uhk-agent-image";
          src = self.fetchurl {
            url = "https://github.com/UltimateHackingKeyboard/agent/releases/download/v${version}/UHK.Agent-${version}-linux-x86_64.AppImage";
            sha256 = "1gr3q37ldixcqbwpxchhldlfjf7wcygxvnv6ff9nl7l8gxm732l6";
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

      neovim = import ./../../nvim-config { };
  };

in {
  imports =
    [ "${nixos-hardware}/lenovo/thinkpad/x1/6th-gen/default.nix"
      <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];
  # Enable S3 suspend state: you have to manually follow the
  # instructions shown here: https://delta-xi.net/#056 in order to
  # produce the ACPI patched table. Put the CPIO archive in /boot and
  # then enable the following lines
  boot.kernelParams = [
    "mem_sleep_default=deep"
  ];
  boot.extraModulePackages = [ ];
  # Early configure the console to make the font readable from the start
  boot.earlyVconsoleSetup = true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

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


  boot.plymouth.enable = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.devNodes = "/dev/mapper";
  boot.zfs.forceImportAll = true;
  boot.zfs.forceImportRoot = true;

  nix.package = pkgs.nixUnstable;
  nix.maxJobs = lib.mkDefault 8;
  nix.useSandbox = true;
  nix.trustedBinaryCaches = [
    "https://hydra.nixos.org"
    "https://cache.dhall-lang.org"
  ];
  nix.binaryCaches = [
    "https://cache.nixos.org"
    "https://cache.dhall-lang.org"
  ];
  nix.binaryCachePublicKeys = [
    "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
    "cache.dhall-lang.org:I9/H18WHd60olG5GsIjolp7CtepSgJmM2CsO813VTmM="
  ];

  nixpkgs.config.allowBroken = false;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreeRedistributable = true;
  nixpkgs.config.firefox.enableGoogleTalkPlugin = true;
  nixpkgs.config.pulseaudio = true;

  nixpkgs.overlays = [
    (import nixpkgs-mozilla)
    custom_pkgs
  ];

  networking.hostId = "4214f894";
  networking.hostName = "grayworm";

  networking.nat.enable = true;
  networking.nat.internalInterfaces = ["ve-+"];
  networking.nat.externalInterface = "wlp3s0";

  networking.extraHosts = ''
    116.203.16.150 floki floki.garbas.si
    127.0.0.1 ${config.networking.hostName}
    ::1 ${config.networking.hostName}
  '';

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];
  networking.firewall.allowedUDPPortRanges = [ { from = 60000; to = 61000; } ];

  networking.networkmanager.enable = true;

  # Enable readable font on console. The example configuration that
  # follows is taliored towards western languages. To see how to
  # configure the font download the source tarball from
  # http://terminus-font.sourceforge.net/ and read the README file on
  # the root dir
  i18n = {
    # this means ISO8859-1 or ISO8859-15 or Windows-1252 codepages
    # (ter-1), 16x32 px (32), normal font weight (n)
    consoleFont = "ter-132n";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
    consolePackages = [ pkgs.terminus_font ];
  };

  time.timeZone = "Europe/Berlin";

  environment.variables.NIX_PATH = lib.mkForce "nixpkgs=/etc/nixos/nixpkgs-channels:nixos-config=/etc/nixos/configuration.nix";
  environment.variables.GIT_EDITOR = lib.mkForce "nvim +startinsert +0";
  environment.variables.EDITOR = lib.mkForce "nvim";
  # Trick firefox so it doesn't create new profiles, see https://github.com/mozilla/nixpkgs-mozilla/issues/163
  environment.variables.SNAP_NAME = "firefox";
  environment.shellAliases =
    { dotfiles = "git --git-dir=$HOME/.dotfiles --work-tree=$HOME";
      moz-cloudops-jenkins = "ssh -N jenkins-proxy & (sleep 5; firefox -P DeployMozAws https://deploy.mozaws.net) && sleep 5 && kill -9 $(jobs -p)";
      moz-cloudops-jenkins2 = "ssh -N jenkins-proxy & (sleep 5; firefox -P DeployMozAws https://ops-master.jenkinsv2.prod.mozaws.net) && sleep 5 && kill -9 $(jobs -p)";
    };

  environment.systemPackages = with pkgs; [
    # mozilla
    phlay

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
    # (vscode-with-extensions.override {
    #    vscodeExtensions = with vscode-extensions; [
    #      bbenoist.Nix
    #      ms-vscode.cpptools
    #      ms-python.python
    #      WakaTime.vscode-wakatime
    #      vscodevim.vim
    #      github.vscode-pull-request-github
    #      akamud.vscode-theme-onelight
    #    ];
    # })


    # IM clients
    skype
    zoom-us

    # mozilla
    arcanist
    ripgrep
    jq
    fzf
    exercism
    travis
    entr
    file
    xorg.xbacklight

    # terminals
    alacritty
    termite
    hyper

    # console programs
    brightnessctl
    asciinema
    docker_compose
    entr
    gnumake
    gnupg
    htop
    mpv
    ngrok
    scrot
    pass
    sshuttle
    tig
    tree
    unzip
    wget
    which
    youtube-dl

    # version controls
    gitAndTools.gitflow
    gitAndTools.hub
    gitFull
    mercurialFull

    # trays / applets
    networkmanagerapplet
    pa_applet
    pasystray
    python3Packages.py3status
    i3status

    # browsers
    latest.firefox-nightly-bin
    # XXX: chromium
    opera

    # GUI applications
    obs-studio
    pavucontrol
    # XXX: pgadmin
    spotify
    uhk-agent

    # i3 and stuff
    gnome3.adwaita-icon-theme
    gnome3.dconf
    gnome3.defaultIconTheme
    gnome3.gnome_themes_standard
    hicolor-icon-theme
    rofi
    rofi-menugen
    rofi-pass
    volumeicon
    xclip
    xlibs.xbacklight
    xlibs.xcursorthemes
    xlibs.xev
    xlibs.xmodmap
    xlibs.xset
    xsel
    iw
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
  programs.zsh.syntaxHighlighting.enable = true;
  programs.zsh.shellInit = ''
    export SPACESHIP_VI_MODE_COLOR=black
  '';
  programs.zsh.ohMyZsh.enable = true;
  programs.zsh.ohMyZsh.plugins =
    [ "git"
      "mosh"
      "pass"
      "vi-mode"
      "zsh-autosuggestions"
      "zsh-syntax-highlighting"
    ];
  programs.zsh.ohMyZsh.theme = "spaceship";

  # Fingerprint reader: login and unlock with fingerprint (if you add one with `fprintd-enroll`)
  services.fprintd.enable = true;

  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";

  services.printing.enable = true;
  services.printing.drivers = with pkgs; [
    hplip
    gutenprint
    gutenprintBin
  ];
  services.avahi.enable = true;
  services.avahi.nssmdns = true;

  services.keybase.enable = true;

  services.udev.packages = with pkgs; [ uhk-agent ];

  sound.enable = true;

  # https://nixos.wiki/wiki/Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.extraConfig = ''
    [General]
    Enable=Source,Sink,Media,Socket
  '';
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
  hardware.pulseaudio.extraModules = [ pkgs.pulseaudio-modules-bt ];
  #hardware.pulseaudio.configFile = pkgs.writeText "default.pa" ''
  #  load-module module-switch-on-connect
  #  load-module module-bluetooth-policy
  #  load-module module-bluetooth-discover
  #  ## module fails to load with 
  #  ##   module-bluez5-device.c: Failed to get device path from module arguments
  #  ##   module.c: Failed to load module "module-bluez5-device" (argument: ""): initialization failed.
  #  # load-module module-bluez5-device
  #  # load-module module-bluez5-discover
  #'';
  hardware.pulseaudio.tcp.enable = true;
  hardware.pulseaudio.tcp.anonymousClients.allowAll = true;
  hardware.pulseaudio.zeroconf.discovery.enable = true;
  hardware.pulseaudio.zeroconf.publish.enable = true;

  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;

  hardware.u2f.enable = true;

  services.logind.lidSwitch = "ignore";
  services.logind.lidSwitchDocked = "ignore";

  services.fstrim.enable = true;
  services.compton.enable = true;
  #services.compton.shadow = true;
  #services.compton.inactiveOpacity = "0.8";
  services.xserver.autorun = true;
  services.xserver.enable = true;
  services.xserver.exportConfiguration = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e, ctrl:nocaps";
  services.xserver.autoRepeatDelay = 200;
  services.xserver.autoRepeatInterval = 25;
  services.xserver.videoDrivers = ["intel"];
  services.xserver.synaptics.enable = false;
  services.xserver.libinput.enable = true;
  services.xserver.libinput.additionalOptions = ''
    Option "Ignore" "true"
  '';

  services.xserver.displayManager.gdm.enable = false;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.lightdm.greeters.gtk.indicators = [ "~host" "~spacer" "~clock" "~spacer" "~a11y" "~session" "~power"];
  services.xserver.windowManager.i3.enable = true;

  services.xserver.desktopManager.default = "xfce";
  services.xserver.desktopManager.xterm.enable = false;
  services.xserver.desktopManager.xfce.enable = true;
  services.xserver.desktopManager.xfce.noDesktop = true;
  services.xserver.desktopManager.xfce.enableXfwm = false;
  #services.xserver.desktopManager.default = "none";
  #services.xserver.desktopManager.xterm.enable = false;

  # TODO: geoclue2 provider is not working
  # TODO: services.redshift.enable = true;
  # TODO: services.redshift.provider = "geoclue2";

  services.timesyncd.enable = true;
  services.dbus.enable = true;
  services.locate.enable = true;
  services.blueman.enable = true;


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

  virtualisation.docker.enable = true;
  # TODO: virtualisation.docker.storageDriver = "overlay2";
  virtualisation.virtualbox.host.enable = true;

  ### services.zfs.autoScrub.enable = true;
  ### services.zfs.autoSnapshot.enable = true;

  ### services.syncthing.enable = true;
  ### services.syncthing.openDefaultPorts = true;
  ### services.syncthing.user = "rok";
  ### services.syncthing.dataDir = "/home/rok/.local/syncthing";

  # services.autorandr.defaultTarget = "mobile";
  # services.autorandr.enable = true;

  # services.znapzend.enable = true;
  # services.znapzend.autoCreation = true;
  # services.znapzend.pure = true;
  # services.znapzend.zetup."main/data" = {
  #   plan = "15min=>5min,1d=>15min,1m=>1d";
  #   destinations.foo = {
  #     dataset = "main/backup/laptop";
  #     host = "192.168.1.25";
  #   };
  # };

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
