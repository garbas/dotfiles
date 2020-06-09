{ config, pkgs, lib, ... }:

let
  # TODO: pin external repos bellow
  # nixos-hardware = builtins.fetchTarball https://github.com/NixOS/nixos-hardware/archive/master.tar.gz;
  # nixpkgs-mozilla = builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz;
  nixos-hardware = ./../../nixos-hardware;
  nixpkgs-mozilla = ./../../nixpkgs-mozilla;
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

    neovim = import ./../../nvim-config { pkgs = self; };
  };
in {
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
      "${nixos-hardware}/lenovo/thinkpad/x220/default.nix"
    ];

  boot.initrd.kernelModules = [ "dm_mod" "dm-crypt" "dm-snapshot" "ext4" "kvm-intel" ];
  boot.initrd.luks.cryptoModules = [ "ecb" ];
  boot.initrd.luks.devices = [ { name = "luksroot"; device = "/dev/sda2"; allowDiscards = true; } ];
  boot.extraModprobeConfig = ''
    options snd_hda_intel index=1,0
    options thinkpad_acpi fan_control=1 force-load=1
  '';
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";
  boot.plymouth.enable = true;
  boot.loader.systemd-boot.enable = true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  nix.maxJobs = 4;
  nix.package = pkgs.nixUnstable;
  nix.useSandbox = true;
  nix.binaryCachePublicKeys = [
    "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
  ];
  nix.trustedBinaryCaches = [ "https://hydra.nixos.org" ];
  nix.extraOptions = ''
    build-cores = 4
    gc-keep-outputs = true
    gc-keep-derivations = true
    auto-optimise-store = true
  '';

  nixpkgs.config.allowBroken = false;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreeRedistributable = true;
  nixpkgs.config.firefox.enableAdobeFlash = true;
  nixpkgs.config.firefox.enableGoogleTalkPlugin = true;
  nixpkgs.config.firefox.jre = false;
  nixpkgs.config.zathura.useMupdf = true;
  nixpkgs.overlays = [
    (import nixpkgs-mozilla)
    custom_pkgs
  ];

  hardware.trackpoint = {
    enable = true;
    sensitivity = 220;
    speed = 0;
    emulateWheel = true;
  };
  hardware.bluetooth.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
  hardware.pulseaudio.extraModules = [ pkgs.pulseaudio-modules-bt ];
  hardware.pulseaudio.tcp.enable = true;
  hardware.pulseaudio.tcp.anonymousClients.allowAll = true;
  hardware.pulseaudio.zeroconf.discovery.enable = true;
  hardware.pulseaudio.zeroconf.publish.enable = true;
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages = [ pkgs.vaapiIntel ];

  hardware.u2f.enable = true;

  virtualisation.virtualbox.host.enable = true;
  virtualisation.docker.enable = true;

  fileSystems."/".label = "root";
  fileSystems."/boot".label = "boot";

  services.acpid.enable = true;
  services.thinkfan.enable = true;
  services.thinkfan.levels = ''
    (0, 0, 45)
    (1, 40, 60)
    (2, 45, 65)
    (3, 50, 75)
    (4, 55, 80)
    (5, 60, 85)
    (7, 65, 32767)
  '';
  services.thinkfan.sensors = ''
    hwmon /sys/class/hwmon/hwmon0/temp1_input
  '';
  services.timesyncd.enable = true;
  services.dbus.enable = true;
  services.locate.enable = true;
  services.blueman.enable = true;
  services.fstrim.enable = true;
  services.compton.enable = true;
  services.nixosManual.showManual = true;
  services.openssh.enable = true;
  services.dbus.packages = with pkgs; [ gnome3.dconf gnome2.GConf ];
  services.printing.enable = true;
  services.printing.drivers = with pkgs; [ hplip ];

  services.xserver.autorun = true;
  services.xserver.desktopManager.gnome3.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.xterm.enable = false;
  services.xserver.enable = true;
  services.xserver.xkbModel = "thinkpad60";
  services.xserver.videoDrivers = [ "intel" ];
  services.xserver.deviceSection = ''
    Option "Backlight" "intel_backlight"
    BusID "PCI:0:2:0"
  '';

  users.defaultUserShell = pkgs.zsh;
  users.mutableUsers = false;
  users.users."marta" = {
    hashedPassword = "$6$7dMLWxcLDtuSYeR$JtD.4LVc3SwB2JZzcjHFllyxtg2hZvoXZ.SJ7SHXaEzJAoFr2t8Sjpmbk3/VNmLNMcIxmOpx.icLy.y5lpSom/";
    isNormalUser = true;
    uid = 1001;
    description = "Marta Rychlewski";
    extraGroups = [ "audio" "wheel" "vboxusers" "networkmanager" ] ;
    group = "users";
    home = "/home/marta";
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

  environment.systemPackages = with pkgs; [
    alacritty
    asciinema
    chromium
    docker_compose
    entr
    entr
    file
    firefox
    fzf
    gitAndTools.git
    gitAndTools.gitflow
    gitAndTools.hub
    gitAndTools.tig
    gitFull
    gnome3.file-roller
    gnumake
    gnupg
    htop
    htop
    hyper
    jq
    libreoffice
    mercurialFull
    mpv
    neovim
    ngrok
    pass
    ripgrep
    scrot
    shotwell
    skype
    sshuttle
    sublime
    tdesktop
    termite
    tig
    travis
    tree
    uhk-agent
    unzip
    vscode
    wget
    which
    youtube-dl
    zathura
    zoom-us
  ];

  fonts.enableFontDir = true;
  fonts.enableGhostscriptFonts = true;
  fonts.fonts = with pkgs; [
    anonymousPro
    corefonts
    dejavu_fonts
    fira-code
    fira-code-symbols
    font-awesome_5
    freefont_ttf
    liberation_ttf
    material-icons
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    powerline-fonts
    source-code-pro
    terminus_font
    ttf_bitstream_vera
  ];

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

  # TODO:networking.hostId = "4214f894";
  networking.hostName = "oskar";
  networking.extraHosts = ''
    116.203.16.150 floki floki.garbas.si
    127.0.0.1 ${config.networking.hostName}
    ::1 ${config.networking.hostName}
  '';
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];
  networking.firewall.allowedUDPPortRanges = [ { from = 60000; to = 61000; } ];
  networking.nat.enable = true;
  networking.nat.internalInterfaces = ["ve-+"];
  networking.nat.externalInterface = "wlp3s0";

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Berlin";

  i18n.consoleFont = "ter-132n";
  i18n.consoleKeyMap = "us";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.consolePackages = [ pkgs.terminus_font ];

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;
  security.hideProcessInformation = true;

  system.autoUpgrade.enable = true;
  system.autoUpgrade.flags = lib.mkForce
    [ "--fast"
      "--no-build-output"
      "-I" "nixpkgs=/etc/nixos/nixpkgs-channels"
    ];

  systemd.extraConfig = ''
    DefaultCPUAccounting=true
    DefaultBlockIOAccounting=true
    DefaultMemoryAccounting=true
    DefaultTasksAccounting=true
  '';
  systemd.services."systemd-vconsole-setup".serviceConfig.ExecStart =
    lib.mkForce
      [ ""
        "${pkgs.systemd}/lib/systemd/systemd-vconsole-setup /dev/tty3"
      ];

  environment.variables.NIX_PATH = lib.mkForce "nixpkgs=/etc/nixos/nixpkgs-channels:nixos-config=/etc/nixos/configuration.nix";
  environment.variables.GIT_EDITOR = lib.mkForce "nvim";
  environment.variables.EDITOR = lib.mkForce "nvim";
}
