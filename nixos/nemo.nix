{ pkgs, ... }:

{
  imports =
    [ ./hw/lenovo-x250.nix 
      (import ./rok.nix { i3_tray_output = "eDP1"; })
    ];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.zfsSupport = true;
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.devNodes = "/dev/mapper";
  boot.zfs.forceImportAll = true;
  boot.zfs.forceImportRoot = true;

  fileSystems."/".device = "rpool/ROOT";
  fileSystems."/".encrypted.enable = true;
  fileSystems."/".encrypted.label = "root_crypt";
  fileSystems."/".encrypted.blkDev = "/dev/sda2";
  fileSystems."/".fsType = "zfs";
  fileSystems."/boot".device = "/dev/sda1";
  fileSystems."/boot".fsType = "vfat";
  fileSystems."/home".device = "rpool/HOME";
  fileSystems."/home".fsType = "zfs";
  fileSystems."/tmp".device = "tmpfs";
  fileSystems."/tmp".fsType = "tmpfs";
  fileSystems."/tmp".options = [ "nosuid" "nodev" "relatime" ];
  fileSystems."/var".device = "rpool/VAR";
  fileSystems."/var".fsType = "zfs";
  fileSystems."/var".options = [ "defaults" "noatime" "acl" ];

  # hostId needed for zsh
  # cksum /etc/machine-id | while read c rest; do printf "%x" $c; done
  networking.hostId = "5eb7479f";

  nix.extraOptions = ''
    build-cores = 4
  '';
  nix.maxJobs = 4;

  networking.hostName = "nemo";

  services.xserver.displayManager.slim.defaultUser = "rok";
  services.xserver.desktopManager.default = "none";

  # XXX: is this needed
  services.xserver.videoDrivers = [ "intel" ];
  services.xserver.deviceSection = ''
    Option "Backlight" "intel_backlight"
    BusID "PCI:0:2:0"
  '';

  #systemd.user.services.dunst = {
  #  enable = true;
  #  description = "Lightweight and customizable notification daemon";
  #  wantedBy = [ "default.target" ];
  #  path = [ pkgs.dunst ];
  #  serviceConfig = {
  #    Restart = "always";
  #    ExecStart = "${pkgs.dunst}/bin/dunst";  # TODO configure theme
  #  };
  #};

  #systemd.user.services.udiskie = {
  #  enable = true;
  #  description = "Removable disk automounter";
  #  wantedBy = [ "default.target" ];
  #  path = with pkgs; [
  #    gnome3.defaultIconTheme
  #    gnome3.gnome_themes_standard
  #    pythonPackages.udiskie
  #  ];
  #  environment.XDG_DATA_DIRS="${pkgs.gnome3.defaultIconTheme}/share:${pkgs.gnome3.gnome_themes_standard}/share";
  #  serviceConfig = {
  #    Restart = "always";  # there is no tray icon
  #    ExecStart = "${pkgs.pythonPackages.udiskie}/bin/udiskie --automount --notify --tray --use-udisks2";
  #  };
  #};

  #systemd.user.services.i3lock-auto = {
  #  enable = true;
  #  description = "Automatically lock screen after 15 minutes";
  #  wantedBy = [ "default.target" ];
  #  path = with pkgs; [ xautolock i3lock-fancy ];
  #  serviceConfig = {
  #    Restart = "always";  # TODO: lockaftersleep does not work
  #    ExecStart = "${pkgs.xautolock}/bin/xautolock -lockaftersleep -detectsleep -time 15 -locker ${pkgs.i3lock-fancy}/bin/i3lock-fancy";
  #  };
  #};

  services.xserver.windowManager.default = "i3";
  services.xserver.windowManager.i3.enable = true;
  services.xserver.windowManager.i3.configFile = "/tmp/config/i3";

  environment.systemPackages = with pkgs;
    [
      gnupg
      gitAndTools.gitflow
      keybase
      mercurialFull
      pass
      taskwarrior
      st  # backup terminal
      vifm
      asciinema
      mpv
      youtube-dl
      pythonPackages.Flootty

      # gui applications
      pavucontrol
      #chromium
      firefox
      pavucontrol
      #skype
      zathura
      VidyoDesktop
      obs-studio

      # gnome3 theme
      gnome3.dconf
      gnome3.defaultIconTheme
      gnome3.gnome_themes_standard
    ];
}
