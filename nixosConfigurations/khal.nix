inputs:
{
  config,
  pkgs,
  lib,
  ...
}:

let
  sshKey = "/home/rok/.ssh/id_ed25519";

  linuxPackages = pkgs.linuxPackages;
  #linuxPackages = pkgs.linuxPackages_5_14;

  swayRun = pkgs.writeShellScript "sway-run" ''
    export XDG_SESSION_TYPE=wayland
    export XDG_SESSION_DESKTOP=sway
    export XDG_CURRENT_DESKTOP=sway

    systemd-run --user --scope --collect --quiet --unit=sway systemd-cat --identifier=sway ${pkgs.sway}/bin/sway $@
  '';
in
{
  imports = [
    (import "${inputs.nixos-hardware}/dell/xps/13-7390/default.nix")
    inputs.home-manager.nixosModules.home-manager
    (import ./profiles/console.nix inputs)
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.rok = import ./../homeConfigurations/wayland.nix {
    username = "rok";
    email = "rok@garbas.si";
    fullname = "Rok Garbas";
    sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPaORav4jLaJ3FfkvlbVPcOT3cZSD4Tk1nywc/hoXBOR rok@khal";
  };

  boot.extraModulePackages = [
    (linuxPackages.v4l2loopback.override { inherit (linuxPackages) kernel; })
  ];
  boot.extraModprobeConfig = ''
    options kvm_intel nested=1
    options kvm_intel emulate_invalid_guest_state=0
    options kvm ignore_msrs=1
    options v4l2loopback exclusive_caps=1 video_nr=9 card_label="obs"
  '';
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "nvme"
    "usb_storage"
    "sd_mod"
    "rtsx_pci_sdmmc"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelPackages = lib.mkForce linuxPackages;
  boot.kernelModules = [
    "kvm-intel"
    "v4l2loopback"
  ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.copyKernels = true;
  #boot.zfs.enableUnstable = true;

  fileSystems."/" = {
    device = "rpool/ROOT";
    fsType = "zfs";
  };

  fileSystems."/home" = {
    device = "rpool/HOME";
    fsType = "zfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/ADB6-356E";
    fsType = "vfat";
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/f38786d1-369a-42e5-8962-13ce86877d98"; }
  ];

  nix.settings.max-jobs = lib.mkDefault 8;
  nix.buildMachines = [
    # tweag remote builders
    {
      hostName = "build01.tweag.io";
      maxJobs = 24;
      sshUser = "nix";
      inherit sshKey;
      system = "x86_64-linux";
      supportedFeatures = [
        "benchmark"
        "big-parallel"
        "kvm"
      ];
    }
    {
      hostName = "build02.tweag.io";
      maxJobs = 24;
      sshUser = "nix";
      inherit sshKey;
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      supportedFeatures = [
        "benchmark"
        "big-parallel"
      ];
    }
  ];

  nixpkgs.config.firefox.enableFoofleTalkPlugin = true;
  #nixpkgs.config.pulseaudio = true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  powerManagement.powertop.enable = true;

  console.keyMap = "us";
  # FIXME: console.font = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";

  networking.hostName = "khal";
  networking.hostId = "b0f5a1e0";
  networking.nat.enable = true;
  networking.nat.internalInterfaces = [ "ve-+" ];
  networking.nat.externalInterface = "wlp2s0";
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];
  networking.firewall.allowedUDPPortRanges = [
    {
      from = 60000;
      to = 61000;
    }
  ];
  networking.networkmanager.enable = true;

  #environment.variables.GDK_DPI_SCALE = "0.5";
  #environment.variables.GDK_SCALE = "2";
  #environment.variables.QT_AUTO_SCREEN_SCALE_FACTOR = "1";
  environment.systemPackages = with pkgs; [
    xorg.setxkbmap # needed by i3status-rust

    # chat
    slack
    zoom-us
    element-desktop
    signal-desktop
    discord

    # terminals
    kitty
    termite
    foot

    # browsers
    firefox
    chromium

    ## i3 related
    #rofi
    #volumeicon
    #xclip

    ## trays / applets
    networkmanagerapplet
    pa_applet
    pasystray

    ## gui tools
    pavucontrol
    transmission-gtk
    uhk-agent
    zathura
    peek

    ## commonly used console utilities
    jq
    entr
    neofetch
    fzf
    ngrok
    zoxide

    ## common console tools
    file
    tree
    unzip
    wget
    which

    ## other console tools
    feh # image viewer
    mpv # video player

    # password managers
    _1password-gui
  ];

  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  services.blueman.enable = true;
  services.dbus.enable = true;
  services.fprintd.enable = true;
  services.fstrim.enable = true;
  services.fwupd.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.printing.drivers = with pkgs; [ hplip ];
  services.printing.enable = true;
  services.thermald.enable = true;
  services.timesyncd.enable = true;
  services.tlp.enable = true;
  services.udev.packages = with pkgs; [ uhk-udev-rules ];
  services.upower.enable = true;
  services.zfs.autoScrub.enable = true;
  services.zfs.autoSnapshot.enable = true;

  services.greetd = {
    enable = true;
    restart = false;
    settings = {
      default_session = {
        command = "${lib.makeBinPath [ pkgs.greetd.tuigreet ]}/tuigreet --time --cmd ${swayRun}";
        user = "greeter";
      };
      initial_session = {
        command = "${swayRun}";
        user = "rok";
      };
    };
  };

  systemd.user.services.ulauncher = {
    enable = true;
    description = "Start Ulauncher";
    script = "${pkgs.ulauncher}/bin/ulauncher --hide-window";
    wantedBy = [
      "graphical.target"
      "multi-user.target"
    ];
    after = [ "greetd.service" ];
  };

  services.pipewire.enable = true;
  services.pipewire.pulse.enable = true;
  services.pipewire.wireplumber.enable = true;
  services.pipewire.media-session.enable = false;

  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-wlr
    xdg-desktop-portal-gtk
  ];

  programs.dconf.enable = true;
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true; # so that gtk works properly
    extraPackages = with pkgs; [
      wofi
      ulauncher

      dmenu-wayland # sway dep
      light # sway dep
      obs-studio
      obs-studio-plugins.wlrobs
      pavucontrol # i3status-rust dep
      playerctl # sway dep
      pulseaudio # i3status-rust dep
      sway-contrib.grimshot # sway dep
      swayidle # sway dep
      swaylock # sway dep
      wf-recorder # sway
      wl-clipboard # sway dep
    ];
  };

  virtualisation.libvirtd.enable = true;
  virtualisation.virtualbox.host.enable = true;

  virtualisation.docker.enable = true;
  # TODO:
  #virtualisation.docker = {
  #  enable = true;
  #  enableOnBoot = true;
  #  extraOptions = ''--config-file=${
  #    pkgs.writeText "daemon.json" (builtins.toJSON {
  #      features = { buildkit = true; };
  #    })
  #  }'';
  #};

  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;

  #hardware.pulseaudio.enable = true;
  #hardware.pulseaudio.package = pkgs.pkgs.pulseaudioFull;
  #hardware.pulseaudio.support32Bit = true;

  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages = with pkgs; [
    intel-media-driver # LIBVA_DRIVER_NAME=iHD
    (vaapiIntel.override { enableHybridCodec = true; }) # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
    vaapiVdpau
    libvdpau-va-gl
  ];
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [
    (vaapiIntel.override { enableHybridCodec = true; }) # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
  ];

  hardware.bluetooth.enable = true;
  hardware.bluetooth.package = pkgs.bluez;
  hardware.bluetooth.settings.General.Experimental = true;

  hardware.cpu.intel.updateMicrocode = true;
  hardware.video.hidpi.enable = true;

  users.mutableUsers = false;
  users.users."root" = {
    hashedPassword = "$6$sBFfflUBZtZMD$h.EWNsmmX8iwTM7jShIvYwvS2/h7dncGTNhG.yPN1dOte1Et0TTz7HSFmzkuWjQpnBAfANYdptF3EQoUNSYwx/";
  };
  users.users."rok" = {
    hashedPassword = "$6$PS.1SD6/$kUv8wdXYH00dEvpqlC9SyX/E3Zm3HLPNmsxLwteJSQgpXDOfFZhWXkHby6hvZ.kFN2JbgXqJvwZfjOunBpcHX0";
    isNormalUser = true;
    uid = 1000;
    description = "Rok Garbas";
    extraGroups = [
      "audio"
      "wheel"
      "vboxusers"
      "networkmanager"
      "docker"
      "libvirtd"
    ];
    group = "users";
    home = "/home/rok";
    shell = pkgs.zsh;
  };

  fonts.enableGhostscriptFonts = true;
  fonts.fontDir.enable = true;
  fonts.fontconfig.antialias = true;
  fonts.fontconfig.defaultFonts.monospace = [ "Fire Code Light" ];
  fonts.fontconfig.defaultFonts.sansSerif = [ "Source Sans Pro" ];
  fonts.fontconfig.defaultFonts.serif = [ "Source Serif Pro" ];
  fonts.fontconfig.enable = true;
  fonts.fonts = with pkgs; [
    # used for terminal
    fira-code
    fira-code-symbols

    # GTK / other UI
    source-sans-pro
    source-serif-pro

    # Fonts use for icons in i3 and powerlevel10k
    nerdfonts

    # Fonts use for icons in i3status-rs
    font-awesome_5
  ];
}
