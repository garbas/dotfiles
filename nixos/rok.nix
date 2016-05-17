{ i3_tray_output }:

{ pkgs, config, ... }:

let

  base16Theme = "default";

  themeUpdateScript = theme: ''
    rm -f /tmp/theme-config
    echo -n "${theme}" > /tmp/theme-config
    cp -f /etc/termite-config-${theme} /tmp/termite-config
    source /etc/setxkbmap-config
    mkdir -p ~/.vim/backup
  '';

  themeDark = pkgs.writeScript "theme-dark" (themeUpdateScript "dark");
  themeLigth = pkgs.writeScript "theme-light" (themeUpdateScript "light");

  i3Packages = with pkgs; {
    inherit i3 i3status feh termite rofi-menugen networkmanagerapplet
      redshift base16 rofi rofi-pass i3lock-fancy;
    inherit (xorg) xrandr xbacklight;
    inherit (pythonPackages) ipython alot py3status;
    inherit (gnome3) gnome_keyring;
  };
  setxkbmapPackages = with pkgs.xorg; { inherit xinput xset setxkbmap xmodmap; };
  zshPackages = with pkgs; { inherit fasd xdg_utils neovim less zsh-prezto; };

in {

  boot.blacklistedKernelModules = [ "snd_pcsp" "pcspkr" ];
  boot.kernelModules = [ "fbcon" "intel_agp" "i915" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  environment.etc."Xmodmap".text = import ./../pkgs/xmodmap_config.nix { };

  environment.etc."gitconfig".text = import ./../pkgs/git_config.nix {
    inherit (pkgs) neovim;
  };

  environment.etc."i3-config".text = import ./../pkgs/i3_config.nix (i3Packages // {
    inherit base16Theme i3_tray_output themeDark themeLigth;
    inherit (pkgs) lib writeScript;
  });

  environment.etc."i3status-config".text = import ./../pkgs/i3status_config.nix {
    inherit base16Theme;
    inherit (pkgs) lib base16;
  };

  environment.etc."setxkbmap-config".text = import ./../pkgs/setxkbmap_config.nix setxkbmapPackages;

  environment.etc."zlogin".text = builtins.readFile "${pkgs.zsh-prezto}/runcoms/zlogin";
  environment.etc."zlogout".text = builtins.readFile "${pkgs.zsh-prezto}/runcoms/zlogout";
  environment.etc."zpreztorc".text = import ./../pkgs/zsh_config.nix (zshPackages);
  environment.etc."zprofile.local".text = builtins.readFile "${pkgs.zsh-prezto}/runcoms/zprofile";
  environment.etc."zshenv.local".text = builtins.readFile "${pkgs.zsh-prezto}/runcoms/zshenv";
  environment.etc."zshrc.local".text = builtins.readFile "${pkgs.zsh-prezto}/runcoms/zshrc";

  environment.etc."termite-config-dark".text = import ./../pkgs/termite_config.nix { inherit pkgs base16Theme; dark = true; };
  environment.etc."termite-config-light".text = import ./../pkgs/termite_config.nix { inherit pkgs base16Theme; dark = false; };

  environment.systemPackages = with pkgs;
    (builtins.attrValues (
      i3Packages //
      setxkbmapPackages //
      zshPackages //
      {})) ++
    [

      termite.terminfo

      # email (TODO: we need to reconfigure mail system)
      pythonPackages.alot
      pythonPackages.afew  # set with timer
      msmtp
      notmuch
      isync
      w3m

      # TODO: needed for vim's syntastic
      csslint
      ctags
      htmlTidy
      phantomjs
      pythonPackages.docutils
      pythonPackages.flake8


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
      pass
      scrot
      st  # backup terminal
      taskwarrior
      unrar
      unzip
      vifm
      wget
      which
      asciinema
      pavucontrol

      # gui applications
      #chromium
      firefox-beta-bin
      pavucontrol
      skype  # doesnt work for some time
      vlc
      mplayer
      zathura
      VidyoDesktop
      #tdesktop

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
    dejavu_fonts
    freefont_ttf
    liberation_ttf
    source-code-pro
    terminus_font
    ttf_bitstream_vera
    nerdfonts
  ];

  i18n.consoleFont = "Lat2-Terminus16";
  i18n.consoleKeyMap = "us";
  i18n.defaultLocale = "en_US.UTF-8";

  networking.extraHosts = ''
    81.4.127.29 floki floki.garbas.si
    127.0.0.1 ${config.networking.hostName}
    ::1 ${config.networking.hostName}
  '';
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 8080 8000 24800 ];
  networking.nat.enable = true;
  networking.nat.internalInterfaces = ["ve-+"];
  networking.nat.externalInterface = "wlp3s0";

  nix.package = pkgs.nixUnstable;
  nix.binaryCachePublicKeys = [
    "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
    "hydra.garbas.si-1:haasp6o2+/uevXZ5i9q4BrgyIu2xL2zAf6hk90EsoRk="
  ];
  nix.trustedBinaryCaches = [ "https://hydra.nixos.org" "http://hydra.garbas.si" ];
  nix.extraOptions = ''
    gc-keep-outputs = true
    gc-keep-derivations = true
    auto-optimise-store = true
    build-use-chroot = relaxed
  '';

  nixpkgs.config.allowBroken = false;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreeRedistributable = true;
  nixpkgs.config.packageOverrides = pkgs: (import ./../pkgs { inherit pkgs; }) // {
    termite = pkgs.termite.override { configFile="/tmp/termite-config"; };
  };


  nixpkgs.config.firefox.enableAdobeFlash = true;
  nixpkgs.config.firefox.enableGoogleTalkPlugin = true;
  nixpkgs.config.firefox.jre = false;
  nixpkgs.config.zathura.useMupdf = true;

  programs.ssh.forwardX11 = false;
  programs.ssh.startAgent = true;
  programs.zsh.enable = true;

  security.sudo.enable = true;
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      var YES = polkit.Result.YES;
      // NOTE: there must be a comma at the end of each line except for the last:
      var permission = {
        // required for udisks1:
        "org.freedesktop.udisks.filesystem-mount": YES,
        "org.freedesktop.udisks.luks-unlock": YES,
        "org.freedesktop.udisks.drive-eject": YES,
        "org.freedesktop.udisks.drive-detach": YES,
        // required for udisks2:
        "org.freedesktop.udisks2.filesystem-mount": YES,
        "org.freedesktop.udisks2.encrypted-unlock": YES,
        "org.freedesktop.udisks2.eject-media": YES,
        "org.freedesktop.udisks2.power-off-drive": YES,
        // required for udisks2 if using udiskie from another seat (e.g. systemd):
        "org.freedesktop.udisks2.filesystem-mount-other-seat": YES,
        "org.freedesktop.udisks2.filesystem-unmount-others": YES,
        "org.freedesktop.udisks2.encrypted-unlock-other-seat": YES,
        "org.freedesktop.udisks2.eject-media-other-seat": YES,
        "org.freedesktop.udisks2.power-off-drive-other-seat": YES
      };
      if (subject.isInGroup("wheel")) {
        return permission[action.id];
      }
    });
  '';

  services.dbus.enable = true;
  services.locate.enable = true;
  services.nixosManual.showManual = true;
  services.openssh.enable = true;

  services.printing.enable = true;
  services.printing.drivers = [ pkgs.brother-hl2030 ];

  services.xserver.autorun = true;
  services.xserver.enable = true;
  services.xserver.exportConfiguration = true;
  services.xserver.layout = "us";
  services.xserver.videoDrivers = [ "intel" ];
  services.xserver.deviceSection = ''
    Option "Backlight" "intel_backlight"
    BusID "PCI:0:2:0"
  '';

  services.xserver.desktopManager.default = "none";
  services.xserver.desktopManager.xterm.enable = false;

  services.xserver.windowManager.default = "i3";
  services.xserver.windowManager.i3.enable = true;
  services.xserver.windowManager.i3.configFile = "/etc/i3-config";

  services.xserver.displayManager.sessionCommands = ''
    ${themeDark}
  '';

  services.xserver.displayManager.slim.defaultUser = "rok";
  services.xserver.displayManager.slim.theme = pkgs.nixos_slim_theme;

  systemd.extraConfig = ''
    DefaultCPUAccounting=true
    DefaultBlockIOAccounting=true
    DefaultMemoryAccounting=true
    DefaultTasksAccounting=true
  '';

  systemd.user.services.dunst = {
    enable = true;
    description = "Lightweight and customizable notification daemon";
    wantedBy = [ "default.target" ];
    path = [ pkgs.dunst ];
    serviceConfig = {
      Restart = "always";
      ExecStart = "${pkgs.dunst}/bin/dunst";
    };
  };

  systemd.user.services.udiskie = {
    enable = true;
    description = "Removable disk automounter";
    wantedBy = [ "default.target" ];
    path = with pkgs; [
      gnome3.defaultIconTheme
      gnome3.gnome_themes_standard
      pythonPackages.udiskie
    ];
    environment.XDG_DATA_DIRS="${pkgs.gnome3.defaultIconTheme}/share:${pkgs.gnome3.gnome_themes_standard}/share";
    serviceConfig = {
      Restart = "always";
      ExecStart = "${pkgs.pythonPackages.udiskie}/bin/udiskie --automount --notify --tray --use-udisks2";
    };
  };

  systemd.user.services.i3lock-auto = {
    enable = true;
    description = "Automatically lock screen after 15 minutes";
    wantedBy = [ "default.target" ];
    path = with pkgs; [ xautolock i3lock-fancy ];
    serviceConfig = {
      Restart = "always";
      ExecStart = "${pkgs.xautolock}/bin/xautolock -lockaftersleep -detectsleep -time 15 -locker ${pkgs.i3lock-fancy}/bin/i3lock-fancy";
    };
  };

  users.mutableUsers = false;
  users.users."root".shell = "/run/current-system/sw/bin/zsh";
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

  time.timeZone = "Europe/Berlin";

  virtualisation.docker.enable = true;
  virtualisation.docker.socketActivation = true;
  virtualisation.virtualbox.host.enable = true;

}
