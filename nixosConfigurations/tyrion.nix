{
  config,
  pkgs,
  lib,
  user,
  hostname,
  inputs,
  customVimPlugins,
  ...
}:
let
  sshKey = "/home/rok/.ssh/id_ed25519";

  #linuxPackages = pkgs.linuxPackages;
  #linuxPackages = pkgs.linuxPackages_5_14;
  linuxPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

  swayRun = pkgs.writeShellScript "sway-run" ''
    export XDG_SESSION_TYPE=wayland
    export XDG_SESSION_DESKTOP=sway
    export XDG_CURRENT_DESKTOP=sway

    systemd-run --user --scope --collect --quiet --unit=sway systemd-cat --identifier=sway ${pkgs.sway}/bin/sway $@
  '';
in {
  imports =
    [ (import "${inputs.nixos-hardware}/lenovo/thinkpad/x220/default.nix")
      inputs.home-manager.nixosModules.home-manager
      (import ./profiles/console.nix inputs)
    ];

  ec2.hvm = true;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = {
    inherit
      user
      inputs
      hostname
      customVimPlugins
      ;
  };
  home-manager.users.${user.username} = import ./../homeConfigurations/profiles/linux.nix;
  home-manager.users.rok = import ./../homeConfigurations/wayland.nix {
    username = "rok";
    email = "rok@garbas.si";
    fullname = "Rok Garbas";
    sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/UvlzfVRvsI8bvy/PE2CTGErPUSRzsCLebGb6Ytc78 rok@tyrion";
  };

  boot.supportedFilesystems = ["zfs"];
  boot.extraModulePackages = [
    (linuxPackages.v4l2loopback.override { inherit (linuxPackages) kernel; })
  ];
  boot.extraModprobeConfig = ''
    options kvm_intel nested=1
    options kvm_intel emulate_invalid_guest_state=0
    options kvm ignore_msrs=1
    options v4l2loopback exclusive_caps=1 video_nr=9 card_label="obs"
  '';
  boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "sr_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelPackages = lib.mkForce linuxPackages;
  boot.kernelModules = [
    "kvm-intel"
    "v4l2loopback"
  ];
  boot.loader.efi.efiSysMountPoint = "/boot/efis/ata-INTEL_SSDSA2CW300G3_CVPR140201HJ300EGN-part1";
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.consoleMode = "auto";
  #boot.zfs.enableUnstable = true;
  boot.zfs.devNodes = "/dev/disk/by-id";

  fileSystems."/" =
    { device = "rpool/nixos/ROOT/default";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/boot" =
    { device = "bpool/nixos/BOOT/default";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/nix" =
    { device = "rpool/nixos/DATA/local/nix";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/home" =
    { device = "rpool/nixos/DATA/default/home";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/root" =
    { device = "rpool/nixos/DATA/default/root";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/srv" =
    { device = "rpool/nixos/DATA/default/srv";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/usr/local" =
    { device = "rpool/nixos/DATA/default/usr/local";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/var/log" =
    { device = "rpool/nixos/DATA/default/var/log";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/var/spool" =
    { device = "rpool/nixos/DATA/default/var/spool";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/state" =
    { device = "rpool/nixos/DATA/default/state";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/etc/nixos" =
    { device = "/state/etc/nixos";
      fsType = "none";
      options = [ "bind" ];
    };

  fileSystems."/etc/cryptkey.d" =
    { device = "/state/etc/cryptkey.d";
      fsType = "none";
      options = [ "bind" ];
    };

  fileSystems."/boot/efis/ata-INTEL_SSDSA2CW300G3_CVPR140201HJ300EGN-part1" =
    { device = "/dev/disk/by-uuid/F220-B691";
      fsType = "vfat";
      options = [ "x-systemd.idle-timeout=1min" "x-systemd.automount" "noauto" ];
    };

  swapDevices = [
    { device = "/dev/disk/by-id/ata-INTEL_SSDSA2CW300G3_CVPR140201HJ300EGN-part4"; randomEncryption.enable = true; }
  ];

  nix.settings.max-jobs = lib.mkDefault 8;
  nix.buildMachines = [
    # tweag remote builders
    #{
    #  hostName = "build01.tweag.io";
    #  maxJobs = 24;
    #  sshUser = "nix";
    #  inherit sshKey;
    #  system = "x86_64-linux";
    #  supportedFeatures = [ "benchmark" "big-parallel" "kvm" ];
    #}
    #{
    #  hostName = "build02.tweag.io";
    #  maxJobs = 24;
    #  sshUser = "nix";
    #  inherit sshKey;
    #  systems = [ "aarch64-darwin" "x86_64-darwin" ];
    #  supportedFeatures = [ "benchmark" "big-parallel" ];
    #}
  ];

  nixpkgs.config.firefox.enableFoofleTalkPlugin = true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  #nixpkgs.config.pulseaudio = true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  powerManagement.powertop.enable = true;

  console.keyMap = "us";
  # FIXME: console.font = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";

  networking.hostName = "tyrion";
  networking.hostId = "be06d0a8";
  networking.nat.enable = true;
  networking.nat.internalInterfaces = ["ve-+"];
  networking.nat.externalInterface = "wlp2s0";
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];
  networking.firewall.allowedUDPPortRanges = [ { from = 60000; to = 61000; } ];
  networking.networkmanager.enable = true;

  environment.etc."machine-id".source = "/state/etc/machine-id";
  environment.etc."zfs/zpool.cache".source = "/state/etc/zfs/zpool.cache";
  #environment.variables.GDK_DPI_SCALE = "0.5";
  #environment.variables.GDK_SCALE = "2";
  #environment.variables.QT_AUTO_SCREEN_SCALE_FACTOR = "1";
  environment.systemPackages = with pkgs; [
    kitty
    termite
    foot
  ];

  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  #services.blueman.enable = true;
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
  services.upower.enable = true;
  services.zfs.autoScrub.enable = true;
  services.zfs.autoSnapshot.enable = true;

  services.greetd = {
    enable = true;
    restart = false;
    settings = {
      default_session = {
        command = "${lib.makeBinPath [pkgs.greetd.tuigreet] }/tuigreet --time --cmd ${swayRun}";
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
    wantedBy = [ "graphical.target" "multi-user.target" ];
    after = [ "greetd.service" ];
  };

  systemd.services.zfs-mount.enable = false;

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
  programs.light.enable = true;
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true; # so that gtk works properly
    extraPackages = with pkgs; [
      wofi
      ulauncher

      dmenu-wayland #sway dep
      obs-studio
      obs-studio-plugins.wlrobs
      pavucontrol #i3status-rust dep
      playerctl #sway dep
      pulseaudio #i3status-rust dep
      sway-contrib.grimshot #sway dep
      swayidle #sway dep
      swaylock #sway dep
      wf-recorder #sway
      wl-clipboard #sway dep
    ];
  };

  #virtualisation.libvirtd.enable = true;
  #virtualisation.virtualbox.host.enable = true;
  #virtualisation.docker.enable = true;
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

  hardware.keyboard.uhk.enable = true;

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

  #hardware.bluetooth.enable = true;
  #hardware.bluetooth.package = pkgs.bluez;
  #hardware.bluetooth.settings.General.Experimental = true;

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
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
    extraGroups = [ "audio" "wheel" "vboxusers" "networkmanager" "docker" "libvirtd" ] ;
    group = "users";
    createHome = true;
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

  system.stateVersion = "22.11";
}
