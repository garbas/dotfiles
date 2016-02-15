{ i3_tray_output }:

{ pkgs, config, ... }:

let

  base16Theme = "default";

  i3Packages = with pkgs; {
    inherit i3 i3lock feh xss-lock dunst pa_applet rxvt_unicode-with-plugins
      networkmanagerapplet redshift base16 rofi rofi-pass;
    inherit (xorg) xrandr;
    inherit (pythonPackages) ipython alot py3status;
    inherit (gnome3) gnome_keyring;
  };
  setxkbmapPackages = with pkgs.xorg; { inherit xinput xset setxkbmap xmodmap; };
  urxvtPackages = with pkgs; { inherit xsel stdenv; };
  zshPackages = with pkgs; { inherit fasd xdg_utils neovim less; };

in {

  boot.blacklistedKernelModules = [ "snd_pcsp" "pcspkr" ];
  boot.kernelModules = [ "fbcon" "intel_agp" "i915" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  environment.etc."Xmodmap".text = import ./../pkgs/xmodmap_config.nix {};
  environment.etc."gitconfig".text = import ./../pkgs/git_config.nix { inherit (pkgs) neovim; };
  environment.etc."i3-config-dark".text = import ./../pkgs/i3_config.nix (i3Packages // { inherit base16Theme i3_tray_output; inherit (pkgs) lib; dark = true; });
  environment.etc."i3-config-light".text = import ./../pkgs/i3_config.nix (i3Packages // { inherit base16Theme i3_tray_output; inherit (pkgs) lib; dark = false; });
  environment.etc."i3status-config".text = import ./../pkgs/i3status_config.nix { inherit base16Theme; inherit (pkgs) lib base16; };
  environment.etc."setxkbmap-config".text = import ./../pkgs/setxkbmap_config.nix setxkbmapPackages;
  environment.etc."urxvt-config".text = import ./../pkgs/urxvt_config.nix urxvtPackages;
  environment.etc."urxvt-themes/${base16Theme}-dark".text = builtins.readFile "${pkgs.base16}/xresources/base16-${base16Theme}.dark.256.xresources";
  environment.etc."urxvt-themes/${base16Theme}-light".text = builtins.readFile "${pkgs.base16}/xresources/base16-${base16Theme}.light.256.xresources";
  environment.etc."zlogin".text = builtins.readFile "${pkgs.zsh-prezto}/runcoms/zlogin";
  environment.etc."zlogout".text = builtins.readFile "${pkgs.zsh-prezto}/runcoms/zlogout";
  environment.etc."zpreztorc".text = import ./../pkgs/zsh_config.nix (zshPackages);
  environment.etc."zprofile.local".text = builtins.readFile "${pkgs.zsh-prezto}/runcoms/zprofile";
  environment.etc."zshenv.local".text = builtins.readFile "${pkgs.zsh-prezto}/runcoms/zshenv";
  environment.etc."zshrc.local".text = builtins.readFile "${pkgs.zsh-prezto}/runcoms/zshrc";
  environment.systemPackages = with pkgs;
    (builtins.attrValues (
      i3Packages //
      setxkbmapPackages //
      urxvtPackages //
      zshPackages //
      {})) ++
    [


      # TODO:
      base16 zsh-prezto # should be included automatically
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

      # gui applications
      chromium
      firefox
      mplayer
      pavucontrol
      skype
      vlc
      zathura
      #VidyoDesktop

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
  nix.binaryCachePublicKeys = [ "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs=" ];
  nix.trustedBinaryCaches = [ "https://hydra.nixos.org" ];
  nix.extraOptions = ''
    gc-keep-outputs = true
    gc-keep-derivations = true
    auto-optimise-store = true
    build-use-chroot = relaxed
  '';

  nixpkgs.config.allowBroken = false;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreeRedistributable = true;
  nixpkgs.config.packageOverrides = pkgs: import ./../pkgs { inherit pkgs; };

  nixpkgs.config.firefox.enableAdobeFlash = true;
  nixpkgs.config.firefox.enableGoogleTalkPlugin = true;
  nixpkgs.config.firefox.jre = false;
  nixpkgs.config.zathura.useMupdf = true;

  programs.ssh.forwardX11 = false;
  programs.ssh.startAgent = true;
  programs.zsh.enable = true;

  security.sudo.enable = true;

  services.dbus.enable = true;
  services.locate.enable = true;
  services.nixosManual.showManual = true;
  services.openssh.enable = true;

  services.printing.enable = true;
  services.printing.drivers = [ pkgs.brother-hl2030 ];

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
    mkdir -p ~/.vim/backup
  '';

  services.xserver.displayManager.slim.defaultUser = "rok";
  services.xserver.displayManager.slim.theme = pkgs.nixos_slim_theme;

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
      Restart = "always";
      ExecStart = "${pkgs.rxvt_unicode-with-plugins}/bin/urxvtd -q -o";
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
